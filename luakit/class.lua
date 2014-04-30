function clone(t)
    local t1 = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            t1[k] = clone(v)
        else
            t1[k] = v
        end
    end
    return t1
end

_G["new"] = {}

function class(className, superClass)
    return function(prototype)
        -- create constructor and place in global "new" object
        new[className] = function(ctorArgs)
            ctorArgs = ctorArgs or {}
            -- create the main reference object for the instance
            local instance = {}
            -- create the object to hold the instance data
            local data = ctorArgs or {}
            -- create getter and setter accessors for instance
            setmetatable(instance, {
                __index = function(self, k)
                    -- getter, use data object which will fall back to prototype object
                    return data[k]
                end,
                __newindex = function(self, k, v)
                    -- setter, check for onChange to give chance to cancel setting value
                    if type(prototype.onChange) == "function" then
                        local bool = prototype.onChange(self, k, v, rawget(data, k))
                        if bool == false then
                            return
                        end
                    end
                    rawset(data, k, v)
                end
            })
            -- set prototype to be lookup after data
            setmetatable(data, {
                __index = prototype
            })
            -- auto-set constructor args
            for k, v in pairs(ctorArgs) do
                instance[k] = v
            end
            -- call constructor (will call inherited constructors if not defined in this class)
            local constructor = prototype.new
            if type(constructor) == "function" then
                -- pass in any constructor params table for reference
                constructor(instance, ctorArgs)
            end
            -- return the instance
            return instance
        end
        -- instal class globally
        _G[className] = prototype
        -- link prototype to superClass prototype if given
        if superClass then
            setmetatable(prototype, {
                __index = superClass
            })
        end
    end
end

local function test()
    describe("Cloning", function ()
        local t1 = {
            x = 1,
            y = {
                z = {
                    2
                },
                3
            },
            z = {"a", "b", "c"}
        }
        local t2 = clone(t1)
        it("should be a table", function ()
            expect(t2).to.be.a("table")
        end)
        it("should have same structure", function ()
            expect(t2).to.have.property("x")
            expect(t2).to.have.property("y")
            expect(t2).to.have.property("z")
            expect(t2.y).to.have.property("z")
            expect(t2.y).to.have.length(1)
            expect(t2.z).to.have.length(3)
        end)
        it("should not modify original object", function()
            t2.x = 4
            t2.y.z[1] = 5
            t2.y[1] = 6
            t2.z[1] = "e"
            t2.z[3] = "f"
            expect(t1.x).to.equal(1)
            expect(t1.y.z[1]).to.equal(2)
            expect(t1.y[1]).to.equal(3)
            expect(t2.z).to.equal({"e", "b", "f"})
        end)
    end)

    describe("Object-Oriented Classes", function ()
        local logs = {}
        local function log(msg)
            logs[#logs + 1] = msg
        end
        local function clearLog()
            logs = {}
        end

        -- base class
        class("Base") {
            x = "baseX",
            y = "baseY",
            baseLocked = 1,
            new = function(self)
                log("Base.new=" .. self.x)
            end,
            baseMethod = function(self, arg)
                log("Base.baseMethod=" .. arg)
            end,
            onChange = function(self, k, v, ov)
                -- allow any property change except baseLocked
                if k == "baseLocked" then return false end
            end
        }

        it("base should create instance with default values", function()
            local a = new.Base()
            expect(a.x).to.equal("baseX")
            expect(a.y).to.equal("baseY")
        end)

        it("base should create instance with custom values", function()
            local a = new.Base{ x = "newBaseX" }
            expect(a.x).to.equal("newBaseX")
            expect(a.y).to.equal("baseY")
            local b = new.Base()
            expect(b.x).to.equal("baseX")
        end)

        it("base should call method", function()
            clearLog()
            local a = new.Base{ x = "newBaseX" }
            a:baseMethod("baseFoo")
            expect(logs).to.equal({"Base.new=newBaseX", "Base.baseMethod=baseFoo"})
        end)

        -- subclass
        class("Sub", Base) {
            x = "subX",
            new = function(self)
                log("Sub.new=" .. self.x)
                Base.new(self)
            end,
            subMethod = function(self, arg1)
                log("Sub.subMethod=" .. arg1)
                Base.baseMethod(self, arg1 .. "@sub")
            end
        }

        it("sub should be able to create instance with default values", function()
            local b = new.Sub()
            expect(b.x).to.equal("subX")
            expect(b.y).to.equal("baseY")
        end)

        it("sub should be able to create instance with custom values", function()
            local b = new.Sub{
                x = "newSubX",
                w = "newSubW"
            }
            expect(b.x).to.equal("newSubX")
            expect(b.y).to.equal("baseY")
            expect(b.w).to.equal("newSubW")
        end)

        it("sub should be able to call base constructor", function()
            clearLog()
            new.Sub { x = "newSubX" }
            expect(logs).to.equal({
                "Sub.new=newSubX",
                "Base.new=newSubX"
            })
        end)

        it("sub should be able to call base method", function()
            local a = new.Sub()
            clearLog()
            a:subMethod("subDoo")
            a:baseMethod("subFoo")
            expect(logs).to.equal({
                "Sub.subMethod=subDoo",
                "Base.baseMethod=subDoo@sub",
                "Base.baseMethod=subFoo"
            })
        end)

        -- sub-subclass
        class("SubSub", Sub) {
            x = "subSubX",
            xyz = 123,
            new = function(self)
                log("SubSub.new=" .. self.x)
                Sub.new(self)
            end,
            subSubMethod = function(self, arg1)
                log("SubSub.subSubMethod=" .. arg1)
                Sub.subMethod(self, arg1 .. "@subSub")
            end,
            onChange = function(self, k, v, ov)
                if k == "y" or k == "z" then return false end
                return Sub.onChange(self, k, v, ov)
            end
        }

        it("subSub should be able to call base constructors", function ()
            clearLog()
            new.SubSub()
            expect(logs).to.equal({
                "SubSub.new=subSubX",
                "Sub.new=subSubX",
                "Base.new=subSubX"
            })
        end)

        it("subSub should be able to call base methods", function()
            local a = new.SubSub()
            clearLog()
            a:subSubMethod("subSubDoo")
            expect(logs).to.equal({
                "SubSub.subSubMethod=subSubDoo",
                "Sub.subMethod=subSubDoo@subSub",
                "Base.baseMethod=subSubDoo@subSub@sub"
            })
        end)

        it("subSub should prevent change to property", function()
            local c = new.SubSub {
                x = "newSubSubX",
                y = "newSubSubY",
                z = "newSubSubZ"
            }
            c.x = "newerSubSubX"
            c.y = "tryToChangeY"
            c.z = "tryToChangeZ"
            c.baseLocked = 2
            expect(c.x).to.equal("newerSubSubX")
            expect(c.y).to.equal("newSubSubY")
            expect(c.z).to.equal("newSubSubZ")
            expect(c.baseLocked).to.equal(1)
        end)
    end)
end

return test