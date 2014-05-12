local sqlite3 = require("sqlite3")

-- result codes
local sqlResultCodes = {
    [0] = "OK",
    [1] = "ERROR",
    [2] = "INTERNAL",
    [3] = "PERM",
    [4] = "ABORT",
    
    [5] = "BUSY",
    [6] = "LOCKED",
    [7] = "NOMEM",
    [8] = "READONLY",
    [9] = "INTERRUPT",
    
    [10] = "IOERR",
    [11] = "CORRUPT",
    [12] = "NOTFOUND",
    [13] = "FULL",
    [14] = "CANTOPEN",
    
    [15] = "PROTOCOL",
    [16] = "EMPTY",
    [17] = "SCHEMA",
    [18] = "TOOBIG",
    [19] = "CONSTRAINT",
    
    [20] = "MISMATCH",
    [21] = "MISUSE",
    [22] = "NOLFS",
    [24] = "FORMAT",
    [25] = "RANGE",
    
    [26] = "NOTADB",
    [100] = "ROW",
    [101] = "DONE"
}
local function getResult(code)
    local result = sqlResultCodes[code]
    if result == nil then
        return "Unknown - " .. code
    else
        return result
    end
end

-- database instance
local database
local queries = {}

-- close db on system applicationExit event
Runtime:addEventListener("system", function(event)
    if event.type == "applicationExit" then
        database:close()
    end
end)

-- module definitions
local module = {}

module.open = function(dbFileName)
    local path = system.pathForFile(dbFileName, system.DocumentsDirectory)
    database = sqlite3.open(path)
end

module.create = function(tableName, columns)
    local sql = "CREATE TABLE " .. tableName .. "("
    local cols = {}
    if columns["id"] == nil then
        columns["id"] = "INTEGER PRIMARY KEY AUTOINCREMENT"
    end
    for k, v in pairs(columns) do
        cols[#cols + 1] = k .. " " .. v
    end
    sql = sql .. table.concat(cols, ", ") .. ")"
    local result = getResult(database:exec(sql))
    console:log("db.create", tableName, result)
end

module.exists = function(tableName)
    local sql = "SELECT count(*) FROM sqlite_master WHERE type='table' AND name='" .. tableName .. "'"
    local query = module.query(sql)
    query:step()
    return query:get_values()[1] == 1
end

module.drop = function(tableName)
    if module.exists(tableName) then
        local result = getResult(database:exec("DROP TABLE " .. tableName))
        console:log("db.drop", tableName, result)
    end
end

module.query = function(sql)
    if queries[sql] == nil then
        queries[sql] = database:prepare(sql)
    end
    queries[sql]:reset()
    return queries[sql]
end

module.queries = function()
    local array = {}
    for k, v in pairs(queries) do
        array[#array + 1] = k
    end
    return array
end

module.select = function(tableName, clause)
    local sql = "SELECT * FROM " .. tableName
    if clause then
        if clause.where then
            sql = sql .. " WHERE " .. clause.where
        end
        if clause.orderBy then
            sql = sql .. " ORDER BY " .. clause.orderBy
        end
        if clause.limit then
            sql = sql .. " LIMIT " .. clause.limit
        end
    end
    local query = module.query(sql)
    local rows = {}
    for row in query:nrows() do
        rows[#rows + 1] = row
    end
    return rows
end

module.count = function(tableName)
    local query = module.query("SELECT count(*) FROM " .. tableName)
    query:step()
    return query:get_values()[1]
end

module.insert = function(tableName, data)
    local sql = "INSERT INTO " .. tableName .. " ("
    local cols = {}
    local values = {}
    for k, v in pairs(data) do
        cols[#cols + 1] = k
        values[#values + 1] = ":" .. k
    end
    sql = sql .. table.concat(cols, ", ") .. ") VALUES("
    sql = sql .. table.concat(values, ", ") .. ")"
    local query = module.query(sql)
    query:bind_names(data)
    query:step()
end

return module