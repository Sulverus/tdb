local fiber = require('fiber')
local socket = require('socket')
local yaml = require('yaml')
local colors = require('ansicolors')
local utils = require 'utils'

local VERSION = 'v.0.0.3'

-- source code cache
local files = {}

-- debugger state
local cur_file = nil
local next_line = false
local run_mode = false
local eval_mode = false
local context = {}

local function load_file(fname)
    io.input(fname)
    files[fname] = {}
    local count = 1
    while true do
        local line = io.read()
        if line == nil then
            break
        end
        files[fname][count] = line
        count = count + 1
    end
end

-- UI
local commands = {
    n = function()
        next_line = true
    end;
    q = function()
        os.exit(0)
    end;
    h = function()
        utils.logger(
            [[
    Help:
            n - next line
            c - continue
            bt - traceback
            locals - get local context
            globals - get global scope
            e - enter to eval mode
            -e - return to default mode
            f - fiber info
            q - exit
            h - help
            ]], colors.green
        )
    end;
    bt = function()
        utils.logger(debug.traceback(), colors.red)
    end;
    c = function()
        run_mode = true
        next_line = true
    end;
    f = function()
        utils.fibers_ui()
    end;
    locals = function()
        utils.print_table(utils.locals(context))
    end;
    globals = function()
        utils.print_table(utils.globals())
    end;
    e = function()
        eval_mode = true
        utils.logger('Eval mode ON', colors.green)
    end;
}

-- check that running code is in context
local function is_traced_code(s)
    if s.short_src == nil then
        return false
    end
    local path, file, _ = string.match(s.short_src, utils.path_regex)
    local path2, arg_file, _ = string.match(arg[0], utils.path_regex)

    return s.func == context.func and file == arg_file
end

-- exec lua string in current execution context
local function eval(cmd)
    local status, err = pcall(function()
        local f = assert(loadstring(cmd))
        print(setfenv(f, utils.get_env(context))())
    end)
    if not status then
        utils.logger(err, colors.red)
    end
end

-- main loop
local function tdb_loop()
    next_line = false
    utils.logger('>', colors.blue, true)

    local cmd = io.read('*line')
    if cmd == '' then
        return 1
    end

    if eval_mode then
        if cmd == '-e' then
            eval_mode = false
            utils.logger('Eval mode OFF', colors.green)
            return
        end

        if utils.find_in_scope(cmd, context) then
            utils.get_variable(cmd, context)
        else
            eval(cmd)
        end
    else
        if commands[cmd] == nil then
            utils.logger('Unknown command. Type h for help.', colors.red)
        else
            commands[cmd]()
        end
    end

    if next_line then
        return 1
    end
end


-- tdb init function
local function debugger(event, line)
    local s = debug.getinfo(2)
    s.short_src = utils.split(s.source, '@')[2]
    if not is_traced_code(s)then
        --print('isn not traced')
        return
    end

    -- load file to sources cache
    if files[s.short_src] == nil then
        print(s.short_src)
        load_file(s.short_src)
    end

    -- set current code file
    if cur_file ~= s.short_src then
        cur_file = s.short_src
        utils.logger('[' .. cur_file .. ']', colors.green)
    end

    -- print code line
    local code = files[s.short_src][line]
    utils.logger(line .. ': ' .. code:gsub("^%s*(.-)%s*$", "%1"))
    io.input(io.stdin)

    -- handle 'continue' command
    if run_mode then
        return
    end

    -- man debugger loop
    while true do
        local exit = tdb_loop()
        if exit ~= nil then
            break
        end
    end
end

-- UI sethock wrapper
local function start(info)
    utils.logger('Tarantool debugger '.. VERSION
        ..'. Type h for help', colors.green)
    debug.sethook(debugger, 'l')
    context = debug.getinfo(2)
    -- fix large filenames
    context.short_src = utils.split(context.source, '@')[2]
end

return {
    start=start;
}
-- vim: ts=4:sw=4:sts=4:et
