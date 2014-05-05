local str = tostring

local results = {
    total = 0,
    passing = 0,
    failing = 0,
    errors = {}
}

logs = {}

function log(msg)
    logs[#logs + 1] = msg
end

function clearLog()
    logs = {}
end

local function report(title)
    console:br()
    local percentPassed = math.round((results.passing / results.total) * 100)
    local status = "OK"
    if percentPassed < 100 then status = "FAILING" end
    local resultsStatus = "\"" .. title .. "\" " .. str(percentPassed) .. "% Passed - " .. status
    local resultsStats = results.total .. " Total - " .. results.passing .. " Passing, " .. results.failing .. " Failing."
    console:push(resultsStatus)
    console:info(resultsStats)
    console:pop()
    console:br()
end

function describe(title, fn)
    console:push(title)
    fn()
    console:pop()
    report(title)
end

function it(title, fn)
    local fail
    results.total = results.total + 1
    console:info(title)
    local result = xpcall(fn, function(err)
        fail = err
        results.errors[#results.errors + 1] = {title = title, error = err}
    end)
    if result then
        results.passing = results.passing + 1
    else
        results.failing = results.failing + 1
        console:push()
        local file, err = fail:match("([a-zA-Z0-9-._\\:]+): (.*)")
        console:error(file)
        console:push()
        console:error(err)
        console:pop()
        console:pop()
    end
end

local function areTablesEqual(_source, _target)
    local ERR_LEVEL = 4
    local msg = "Expected tables to be equal"
    if type(_source) ~= "table" then error(msg .. ", source is a " .. type(_source), ERR_LEVEL) end
    if type(_target) ~= "table" then error(msg .. ", target is a " .. type(_target), ERR_LEVEL) end
    local function _areTablesEqual(source, target)
        if #source ~= #target then error(msg .. " with length of " .. str(#source) .. ", found target length of " .. str(#target), ERR_LEVEL) end
        for k, v in pairs(source) do
            if target[k] == nil and source[k] ~= nil then error(msg .. ", target is missing property '" .. k .. "'", ERR_LEVEL) end
            if type(source[k]) ~= type(target[k]) then error(msg .. ", expecting target value at index '" .. k .. " to be a " .. type(source[k]) .. ", found a " .. type(target[k]), ERR_LEVEL) end
            if type(source[k]) == "table" then
                _areTablesEqual(source[k], target[k])
            else
                if target[k] ~= source[k] then error(msg .. ", expecting target value at index '" .. k .. " to be \"" .. str(source[k]) .. "\", found " .. str(target[k]), 4) end
            end
        end
        for k, v in pairs(target) do
            if source[k] == nil and target[k] ~= nil then error(msg .. ", target has extra property \"" .. k .. "\"", ERR_LEVEL) end
        end
    end
    _areTablesEqual(_source, _target)
end

function expect(actualValue)
    return {
        to = {
            equal = function(expectedValue)
                if type(actualValue) == "table" then
                    areTablesEqual(expectedValue, actualValue)
                else
                    if actualValue ~= expectedValue then error("Expected " .. str(actualValue) .. " to be " .. str(expectedValue), 2) end
                end
            end,
            be = {
                a = function(expectedType)
                    if type(actualValue) ~= expectedType then error("Expected " .. str(actualValue) .. " to be a " .. expectedType, 2) end
                end
            },
            have = {
                length = function(expectedLength)
                    if #actualValue ~= expectedLength then error("Expected table length to be " .. str(expectedLength) .. " found " .. str(#actualValue), 2) end
                end,
                item = function(expectedItem)
                    local containsItem = false
                    for i = 1, #actualValue do
                        if actualValue[i] == expectedItem then containsItem = true end
                    end
                    if not containsItem then error("Expected table to contain item '" .. str(expectedItem) .. "'", 2) end
                end,
                property = function(expectedProperty)
                    local containsProperty = false
                    for k, v in pairs(actualValue) do
                        if k == expectedProperty then containsProperty = true end
                    end
                    if not containsProperty then error("Expected table to contain property '" .. str(expectedProperty) .. "'", 2) end
                end
            }
        }
    }
end

local function test()
    describe("test suite 1", function()
        it("shoule be test 1.a", function()
            expect(true).to.equal(true)
            expect(1).to.be.a("number")
        end)
        it("should be test 2.a", function()
            expect({1,2,3}).to.have.length(3)
        end)
    end)

    describe("test suite 2", function()
        it("shoule be test 2.a", function()
            expect({"a", "b", "c"}).to.have.item("b")
            expect({x = 1, y = 2}).to.have.property("x")
            expect({"a", "b", "c"}).to.equal({"a", "b", "c"})
        end)
        it("should be test 2.b", function()
            local t1 = {1, 2, {
                x = 1
            }}
            local t2 = {1, 2, {
                x = 1
            }}
            areTablesEqual(t1, t2)
        end)
    end)
end

return test