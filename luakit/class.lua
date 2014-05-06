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

Object = {
    copy = function()
        -- todo: duplicate construction or share new code?
    end,
    instanceOf = function(self, prototype)
        local proto = self.prototype
        while proto ~= nil do
            if proto == prototype then
                return true
            end
            proto = proto.super
        end
        return false
    end,
    rawget = function(self, k)
        return rawget(self.__data, k)
    end,
    rawset = function(self, k, v)
        rawset(self.__data, k, v)
    end
}

function instanceOf(instance, className)
    if type(instance.instanceOf) == "function" then
        return instance:instanceOf(_G[className])
    end
    return type(instance) == className
end

function class(className, superClass)
    return function(prototype)
        prototype.className = className
        -- create constructor and place in global "new" object
        new[className] = function(args)
            -- create the main reference object for the instance
            local instance = {
                prototype = prototype
            }
            -- create the object to hold the instance data
            args = args or {}
            -- copy the args into the new data object
            local data = {}
            for k, v in pairs(args) do
                rawset(data, k, v)
            end
            -- create getter and setter accessors for instance
            setmetatable(instance, {
                __index = function(self, k)
                    -- getter, use data object which will fall back to prototype object
                    local getter = prototype.get
                    if type(getter) == "function" then
                        if k == "__data" then
                            return data
                        end
                        local v = getter(self, k)
                        if v ~= nil then
                            return v
                        end
                    end
                    return data[k]
                end,
                __newindex = function(self, k, v)
                    -- setter, check for set to give chance to cancel setting value
                    local setter = prototype.set
                    if type(setter) == "function" then
                        local ov = data[k]
                        local bool = setter(self, k, v, ov)
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
            -- call constructor (will call inherited constructors if not defined in this class)
            local constructor = prototype.new
            if type(constructor) == "function" then
                -- pass in any constructor params table for reference
                constructor(instance, args)
            end
            -- return the instance
            return instance
        end
        -- instal class globally
        _G[className] = prototype
        -- link prototype to superClass prototype if given
        if superClass then
            -- link to super class
            prototype.super = superClass
            setmetatable(prototype, {
                __index = superClass
            })
        else
            -- no super, link to Object
            prototype.super = Object
            setmetatable(prototype, {
                __index = Object
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
        -- base class
        class("Base") {
            x = "baseX",
            y = "baseY",
            z = {a = 1, b = 2},
            baseLocked = 1,
            new = function(self)
                log("Base.new=" .. self.x)
            end,
            baseMethod = function(self, arg)
                log("Base.baseMethod=" .. arg)
            end,
            set = function(self, k, v, ov)
                -- allow any property change except baseLocked
                if k == "baseLocked" then return false end
            end
        }

        it("base should create instance with default values", function()
            local a = new.Base()
            expect(a.x).to.equal("baseX")
            expect(a.y).to.equal("baseY")
            expect(a.className).to.equal("Base")
            expect(a.prototype).to.equal(Base)
            expect(a.prototype.super).to.equal(Object)
            expect(a:instanceOf(Object)).to.equal(true)
            expect(a:instanceOf(Base)).to.equal(true)
            expect(instanceOf(a, "Base")).to.equal(true)
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
            expect(b.className).to.equal("Sub")
            expect(b.prototype).to.equal(Sub)
            expect(b.prototype.super).to.equal(Base)
            expect(b:instanceOf(Object)).to.equal(true)
            expect(b:instanceOf(Base)).to.equal(true)
            expect(b:instanceOf(Sub)).to.equal(true)
            expect(instanceOf(b, "Object")).to.equal(true)
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
            set = function(self, k, v, ov)
                if k == "y" or k == "z" then return false end
                return Sub.set(self, k, v, ov)
            end
        }

        it("subSub should be able to call base constructors", function ()
            clearLog()
            local c = new.SubSub()
            expect(logs).to.equal({
                "SubSub.new=subSubX",
                "Sub.new=subSubX",
                "Base.new=subSubX"
            })
            expect(c.className).to.equal("SubSub")
            expect(c.prototype).to.equal(SubSub)
            expect(c.prototype.super).to.equal(Sub)
            expect(c.prototype.super.super).to.equal(Base)
            expect(c:instanceOf(Object)).to.equal(true)
            expect(c:instanceOf(Base)).to.equal(true)
            expect(c:instanceOf(Sub)).to.equal(true)
            expect(c:instanceOf(SubSub)).to.equal(true)
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