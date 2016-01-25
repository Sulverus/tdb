local colors = require('ansicolors')
local fiber = require('fiber')


local path_regex = "(.-)([^\\/]-%.?([^%.\\/]*))$"
local function logger(msg, color, eoln)
    local line = colors.blue .. '(TDB)'
    if eoln == nil then
        line = line .. ' '
    end
    line = line .. colors.reset

    if color ~= nil then
        msg = color .. msg .. colors.reset
    end

    if eoln == nil then
        msg = msg .. '\n'
    end

    io.output(io.stdout)
    io.write(line .. msg)
end

local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

local function print_table(t)
    for key, val in pairs(t) do
        print(key, val)
    end
end

local function print_in_table(t, key)
    local elem = rawget(t, key)
    if elem == nil then
        return
    end
    local elem = t[key]
    if type(elem) == 'table' then
        print(tostring(elem) ..':')
        print_table(elem)
    else
        print(key, elem)
    end
end

function split(str, delim)
    if string.find(str, delim) == nil then
        return { str }
    end
    local result,pat,lastpos = {},"(.-)" .. delim .. "()",nil
    for part, pos in string.gfind(str, pat) do
        table.insert(result, part)
        lastpos = pos
    end
    table.insert(result, string.sub(str, lastpos))
    return result
end

local function globals()
    return _G
end

local function locals(context)
    -- find stack level
    local level = 1
    for i, s in pairs(split(debug.traceback(), '\n')) do
        local filename = trim(split(s, ':')[1])

        local _, file, _ = string.match(filename, path_regex)
        local _, src, _ = string.match(context.short_src, path_regex)
        if file == src then
            level = i - 1
            break
        end
    end

    -- collect all variables
    local variables = {}
    local idx = 1
    while true do
        local ln, lv = debug.getlocal(level, idx)
        if ln ~= nil then
            variables[ln] = lv
        else
            break
        end
        idx = 1 + idx
    end
    return variables
end


local function find_in_scope(key, context)
    return rawget(locals(context), key) ~= nil or
        rawget(globals(), key) ~= nil
end

local function get_variable(key, context)
    print_in_table(globals(), key)
    print_in_table(locals(context), key)
end

local function get_env(cont)
    local context = {}
    for k,v in pairs(globals()) do
        context[k] = v
    end
    for k,v in pairs(locals(cont)) do
        context[k] = v
    end
    return context
end

local function fibers_ui()
    local info = fiber.info()
    logger('Running fibers list:', colors.blue)
    logger('id\tname\t\t\tmemory, %')
    logger('--------------------------------------------------')
    for id, f in pairs(info) do
        local memory = 100 * tonumber(f.memory.used/f.memory.total)
        local msg = tostring(id) .. '\t' .. f.name
        msg = msg .. '\t\t' .. tostring(memory)
        logger(msg)
    end
    logger('--------------------------------------------------')
end

return {
    logger = logger,
    globals = globals,
    find_in_scope = find_in_scope,
    get_variable = get_variable,
    get_env = get_env,
    print_table = print_table,
    fibers_ui = fibers_ui,
    split = split,
    trim = trim,
    locals = locals,
    path_regex = path_regex
}
-- vim: ts=4:sw=4:sts=4:et
