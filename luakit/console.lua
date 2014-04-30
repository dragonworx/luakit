function alert(message)
    native.showAlert("Alert", message)
end

local config = {
    enabled = true,
    logToDisk = false,
    title = "Lua Console by DRAGONWORX",
    lineNumberCharSize = 3,
    itemTypeCharSize = 5,
    logFilter = { "group", "verbose", "log", "info", "warn", "error", "start", "complete", "close", "break" },
    padding = "|   ",
    groupSize = 40
}

local logFilePath = system.pathForFile("log.txt", system.DocumentsDirectory)
if config.logToDisk == true then
    os.remove(logFilePath)
end

local function stdout(str)
    -- print to terminal
    print(str)

    if config.logToDisk == true then
        -- write to log.txt in documents directory
        local path = logFilePath
        local file = io.open(path, "a")
        file:write(str .. "\n")
        io.close(file)
        file = nil
    end
end


-- module.lua
local function ConsoleCore(config)

    local modulePrototype = {
        openGroup = function() end,
        closeGroup = function() end,
        writeLine = function() end,
        openItem = function() end,
        closeItem = function() end,
        open = function() end,
        close = function() end,
        clear = function() end
    }

    -- console module
    local module = {
        isFirstLine = true,
        buffer = {__mode = "kv"},
        title = config.title,
        groupStack = {
            {
                name = config.title or defaultTitle,
                type = "group"
            }
        },
        currentItem = nil,
        isNewLine = true,
        lineCount = 0,
        listeners = {},
        listener = nil
    }

    function module.padding (level)
        if level == 0 then
            return ""
        end
        return string.rep("\t", level)
    end

    function module.lineInc()
        module.lineCount = module.lineCount + 1
        local str = "" .. module.lineCount
        if #str > config.lineNumberCharSize then
            module.lineCount = 1
        end
    end

    function module.lineNumber(i, l)
        local pad = i .. ""
        if #pad < l then
            pad = string.rep("0", l - #pad) .. pad
        end
        pad = pad .. ""
        return pad
    end

    function module.print (str)
        if config.enabled then
            stdout(str)
        end
    end

    function module.centerString (innerStr, outerStr)
        local left = string.sub(outerStr, 1, (#outerStr / 2) - (#innerStr / 2))
        local right = string.sub(outerStr, (#outerStr / 2) + (#innerStr / 2) + 1)
        return left .. innerStr .. right
    end

    function module.write (str)
        if module.isNewLine then
            module.isNewLine = false
        end
        module.buffer[#module.buffer + 1] = str
    end

    function module.writeBreak ()
        module.flush()
        module.isNewLine = true
    end

    function module.flush ()
        local str = table.concat(module.buffer, "")
        module.listener:writeLine(str, module.listener.level, module.padding(module.listener.level), module.lineCount)
        module.buffer = {__mode = "kv" }
    end

    local function count(t)
        local c = 0
        for k, v in pairs(t) do
            c = c + 1
        end
        return c
    end

    function module.serialize (value, valueOnly, node)
        local hash = {__mode = "kv" }
        local tables = {__mode = "kv" }

        local function _serialize (_value, node)
            if _value == nil then
                if not valueOnly then
                    module.write("nil")
                end
                return 'nil'
            end
            if type(_value) == "boolean" then
                if not valueOnly then
                    if _value == true then
                        module.write("true")
                    else
                        module.write("false")
                    end
                end
                return _value
            end
            if type(_value) == "table" and count(_value) == 0 then
                module.write("{}")
                return "{}"
            end
            if (type(_value) == "table" or type(_value) == "function") and hash[_value] then
                if not valueOnly then
                    module.write(hash[_value])
                end
                return hash[_value]
            end
            if type(_value) == "string" then
                local str = string.format("%q", _value)
                if node.type ~= "log" then str = _value end
                if not valueOnly then
                    module.write(str)
                end
                return str
            elseif type(_value) == "table" then
                local className = ""
                if type(_value.toString) == "function" then
                    className = "<" .. _value.__className .. ":" .. (_value.id or "") .. ">"
                end
                if _value._class then
                    className = "<CoronaObj" .. ":" .. (#tables + 1) .. ">"
                end
                tables[_value] = className
                table.insert(tables, tables[_value])
                hash[_value] = tables[_value]
                if _value._class then
                    if not valueOnly then
                        module.write(className)
                    end
                    return className
                end
                if not valueOnly then
                    module.write(hash[_value] .. "{")
                    module.writeBreak()
                end
                module.listener.level = module.listener.level + 1
                for k, v in pairs(_value) do
                    if not valueOnly then
                        if type(k) == "number" then
                            module.write('[' .. k .. ']' .. " = ")
                        else
                            module.write('["' .. k .. '"]' .. " = ")
                        end
                    end
                    _serialize(v, node)
                    if not valueOnly then
                        module.write(",")
                        module.writeBreak()
                    end
                end
                module.listener.level = module.listener.level - 1
                if not valueOnly then
                    module.write("}")
                end
                return tables[_value]
            elseif type(_value) == "function" then
                local info = debug.getinfo(_value)
                local funcDesc = "<function:" .. info.source .. ":" .. info.linedefined .. ">"
                hash[_value] = funcDesc
                if not valueOnly then
                    module.write(funcDesc)
                end
                return funcDesc
            else
                if not valueOnly then
                    module.write(_value)
                end
                return _value
            end
        end

        return _serialize(value, node)
    end

    local function publish (node)
        for i = 1, #module.listeners do
            module.listener = module.listeners[i]
            if node.type == "group" then
                if node.pop then
                    -- pop group
                    table.remove(module.groupStack, #module.groupStack)
                    if module.shouldLog(node.type) then
                        module.listener:closeGroup(node.name, module.listener.level, module.padding(module.listener.level), module.lineCount)
                    end
                    module.listener.level = module.listener.level - 1
                else
                    -- push group
                    module.listener.level = module.listener.level + 1
                    if node.name ~= nil then module.newGroup(node) end
                end
            else
                -- items
                module.currentItem = node

                if module.shouldLog(node.type) then
                    module.listener:openItem(node, module.listener.level, module.padding(module.listener.level), module.lineCount)
                    if #node.values == 0 then
                        module.write("nil")
                    else
                        for j = 1, node.values.n do
                            module.serialize(node.values[j], nil, node)
                            if j < node.values.n then
                                module.write(", ")
                            end
                        end
                    end
                    module.isNewLine = true
                    module.flush()
                    module.listener:closeItem(node, module.listener.level, module.padding(module.listener.level), module.lineCount)
                else
                    module.isNewLine = true
                end
            end
        end
    end

    function module.newGroup(group)
        table.insert(module.groupStack, group)
        if module.shouldLog(group.type) then
            module.listener:openGroup(group.name, module.listener.level, module.padding(module.listener.level), module.lineCount)
        end
    end

    function module.currentGroup ()
        return module.groupStack[#module.groupStack]
    end

    function module.shouldLog(type)
        for i = 1, #config.logFilter do
            if type == config.logFilter[i] then
                return true
            end
        end
        return false
    end

    module.publish = publish

    -- install global
    local console = {
        config = config
    }
    _G["console"] = console

    function console:addEventListener (listener)
        table.insert(module.listeners, listener)
        setmetatable(listener, {__index = modulePrototype})
        listener.level = -1
    end

    function console:push (groupName)
        console:checkFirstLine()
        --module.lineInc()
        module.publish {
            type = "group",
            name = groupName
        }
    end

    function console:pop ()
        module.publish {
            type = "group",
            pop = true
        }

    end

    function console:verbose (...)
        console:write("verbose", arg)
    end

    function console:info (...)
        console:write("info", arg)
    end

    function console:log (...)
        console:write("log", arg)
    end

    local function br (...)
        console:write("break", arg)
    end

    function console:br ()
        br(string.rep(". ", config.groupSize / 2))
    end

    function console:warn (...)
        console:write("warn", arg)
    end

    function console:error (...)
        console:write("error", arg)
    end

    function console:start (...)
        console:write("start", arg)
    end

    function console:complete (...)
        console:write("complete", arg)
    end

    function console:checkFirstLine()
        if module.isFirstLine then
            module.publish {
                type = "group",
                name = module.title
            }
            module.isFirstLine = false
        end
    end

    function console:write (type, args)
        console:checkFirstLine()
        module.lineInc()
        if #type > config.itemTypeCharSize then
            type = string.sub(type, #type - config.itemTypeCharSize + 1)
        end
        module.publish {
            type = type,
            values = args
        }
    end

    function console:enable ()
        module.publish = publish
        config.enabled = true
    end

    function console:disable()
        module.publish = function() end
        config.enabled = false
    end

    function console:close()
        if not config.enabled or not module.listener then return end
        console:write("close", {"Console closed."})
        for i = 1, #module.listeners do
            module.listener = module.listeners[i]
            module.listener:closeGroup(module.groupStack[1].name, module.listener.level, module.padding(module.listener.level), module.lineCount)
            module.listener.level = module.listener.level - 1
            module.listener:close()
        end
    end

    function console:clear()
        module.buffer = {__mode = "kv" }
        for k,v in pairs(module.groupStack) do module.groupStack[k]=nil end
        module.groupStack = {
            {
                name = module.title,
                type = "group"
            }
        }
        module.isNewLine = true
        module.lineCount = 0

        for i = 1, #module.listeners do
            module.listener = module.listeners[i]
            module.listener:clear()
            --module.initListener(module.listener)
        end
    end

    function console:setTitle(title)
        module.title = title
    end

    function console:run(func, shouldCloseAfter, errorHandler)
        local funcName = module.serialize(func, true)
        console:start(funcName)
        local status = xpcall(func, function(err)
            console:error(err)
            console:error(debug.traceback())
            if errorHandler and type(errorHandler == "function") then
                errorHandler(err)
            end
        end)
        if status then
            console:complete(funcName)
        end
        if shouldCloseAfter then
            console:close()
        end
    end

    function console:main (func, errorHandler)
        return console:run(func, true, errorHandler)
    end

    function console:showLog ()
        local webView = native.newWebView(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
        webView:request("log.txt", system.DocumentsDirectory)
    end

    if config.enabled == false then
        console:disable()
    end

    -- module return
    return module
end

-- create instance of core
local consoleMod = ConsoleCore(config)

-- terminal.lua
local module = {
    padding = config.padding,
    lastLineType = nil,
    lastLineNumber = nil,
    groupCharWidth = config.groupSize,
    margin = ""
}

function module:writeLine(str, level, padding, lineCount)
    str = consoleMod.padding(level) .. str
    local type = consoleMod.currentItem.type
    type = string.sub(type, 1, 3)
    if type == "bre" then type = "---" end
    local fill = nil
    if lineCount == module.lastLineNumber then
        fill = string.rep(" ", config.itemTypeCharSize + 3)
        str = string.gsub(str, "\t", module.padding)
        str = module.margin .. consoleMod.lineNumber(lineCount, config.lineNumberCharSize) .. ":" .. fill .. str
    else
        fill = "[" .. string.rep(" ", config.itemTypeCharSize) .. "]"
        str = string.gsub(str, "\t", module.padding)
        local label = consoleMod.centerString(string.upper(type), fill)
        str = module.margin .. consoleMod.lineNumber(lineCount, config.lineNumberCharSize) .. ":" .. label .. " " .. str
    end
    consoleMod.print(str)
    module.lastLineType = type
    module.lastLineNumber = lineCount
end

function module:openGroup(name, level, padding, lineCount)
    padding = module.margin .. string.rep(" ", config.lineNumberCharSize) .. ":" .. string.rep(" ", config.itemTypeCharSize + 3) .. string.rep(module.padding, level)
    local midPadding = module.margin .. string.rep("-", config.lineNumberCharSize) .. ":" .. string.rep("-", config.itemTypeCharSize + 3) .. string.rep("-", #string.rep(module.padding, level))
    local barLine = padding .. "+" .. string.rep("-", module.groupCharWidth - 2) .. "+"
    local midLine = midPadding .. "+" .. string.rep(" ", (module.groupCharWidth - 2 - #name) * 0.5) .. " " .. name .. " " .. string.rep(" ", (module.groupCharWidth - #name - 2) * 0.5) .. "|"
    if #midLine > #barLine then
        barLine = padding .. "+" .. string.rep("-", #midLine - 2 - #padding) .. "+"
    end
    local breakLine = padding .. "|" .. string.rep(" ", #midLine - 2 - #padding) .. "|"

    consoleMod.print(barLine)
    consoleMod.print(midLine)
    consoleMod.print(barLine)
end

function module:clear()
    consoleMod.print("\n \n \n")
end

function module:close()
    consoleMod.print(">")
end

console:addEventListener(module)

local function test ()
    console:run(function()
        local t = {x=1, {1,2,3}, {4,5,6}, [3]="abc"}
        local a = {y=2, t=t, f = function() end}
        t.a = a

        local function func()
            return "abc"
        end

        console:verbose("hi")
        console:info("yo", "there", nil, "a", nil)
        console:info(nil, false)
        console:info(123, func, true)
        console:warn(t)
        console:push("subGroup")
        console:info("hello", "again")
        console:info("hi", t, "there", 123)
        console:push("subSubGroup")
        console:info("hello", "again")
        console:pop()
        console:error(a)
        console:pop()
        console:info("hi yoå")
        console:clear()
        console:verbose("hello")
    end)
end

return test