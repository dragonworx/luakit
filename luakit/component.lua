class("Component") {
    parent = nil,
    children = nil,
    new = function(self, args)
        self:rawset("listeners", {})
        self:rawset("children", {})
        for key, child in pairs(args) do
            if instanceOf(child, "Component") then
                self:addChild(child)
            end
            if instanceOf(child, "function") then
                self:rawset(key, child)
            end
        end
        local id = self.id
        if id ~= nil then
            _G[id] = self
        end
    end,
    init = function(self)
        local init = self._init
        if type(init) == "function" then
            init(self)
        end
    end,
    get = function(self, k)
        if type(k) == "number" then
            return self.children[k]
        end
        if k == "root" then
            local parent = self.parent
            while parent ~= nil do
                if parent.parent == nil then
                    return parent
                end
                parent = parent.parent
            end
        end
        if k == "index" then
            return table.indexOf(self.parent.children, self)
        end
        local getter = self._get
        if type(getter) == "function" then
            return getter(self, k)
        end
    end,
    set = function(self, k, v, ov)
        local setter = self:rawget("_set")
        if type(setter) == "function" then
            return setter(self, k, v, ov)
        end
    end,
    addEventListener = function(self, eventType, listener, handlerName)
        local listeners = self.listeners
        local bindings = listeners[eventType]
        if bindings == nil then
            bindings = {}
            listeners[eventType] = bindings
        end
        bindings[#bindings + 1] = {listener = listener, handlerName = handlerName}
    end,
    removeEventListener = function(self, eventType, listener, handlerName)
        local bindings = self.listeners[eventType]
        if bindings ~= nil then
            for i = 1, #bindings do
                local binding = bindings[i]
                if binding.listener == listener and binding.handlerName == handlerName then
                    table.remove(bindings, i)
                    return
                end
            end
        end
    end,
    sendEvent = function(self, eventType, data)
        local bindings = self.listeners[eventType]
        if bindings ~= nil then
            for i = 1, #bindings do
                local binding = bindings[i]
                local listener = binding.listener
                local handler = listener[binding.handlerName]
                if type(handler) == "function" then
                    handler(listener, data)
                end
            end
        end
        self:onEvent(eventType, data)
    end,
    onEvent = function(self, eventType, data)
        local parent = self.parent
        if parent ~= nil then
            parent:onEvent(eventType, data)
        end
    end,
    addChild = function(self, child)
        local children = self.children
        children[#children + 1] = child
        child.parent = self
        local id = child.id
        if id then
            self[id] = child
        end
        child:init()
    end,
    removeChild = function(self, child)
        local children = self.children
        table.remove(children, table.indexOf(children, child))
        child.parent = nil
        local id = child.id
        if id then
            self[id] = nil
        end
    end,
    setWithDelay = function(self, delay, k, v)
        timer.performWithDelay(delay, function()
            self[k] = v
        end)
    end,
    dispose = function(self)
        -- remove listeners
        local listeners = self.listeners
        for eventType, bindings in pairs(listeners) do
            for i = 1, #bindings do
                local binding = bindings[i]
                binding.listener = nil
                table.remove(bindings, i)
            end
            listeners[eventType] = nil
        end
        -- dettach from parent
        self.parent:removeChild(self)
        -- remove children
        local children = self.children
        for i = 1, #children do
            children[i]:dispose()
            children[i] = nil
        end
    end
}

function test()
    describe("Component - Events", function()
        class("A", Component) {}
        class("B", Component) {
            onTest = function(self, data)
                log(self.name)
            end
        }

        it("should be able to add,remove, send events", function()
            clearLog()

            local a = new.A {name = "a"}
            local b = new.B {name = "b"}
            local c = new.B {name = "c"}

            a:addEventListener("test", b, "onTest")
            a:addEventListener("test", c, "onTest")
            a:sendEvent("test")
            a:removeEventListener("test", b, "onTest")
            a:sendEvent("test")

            expect(logs).to.equal({"b", "c", "c"})
        end)
    end)

    describe("Component - Nesting", function()
        class("A", Component) {
            new = function(self, args)
                log("new A")
                Component.new(self, args)
            end,
            addChild = function(self, child)
                log("add " .. child.className)
                Component.addChild(self, child)
            end
        }

        class("B", Component) {
            new = function(self, args)
                log("new B")
                Component.new(self, args)
            end
        }

        it("should be able to add child components through constructor and composition", function()
            clearLog()
            local a = new.A {
                new.B {}
            }
            expect(logs).to.equal({"new B", "new A", "add B"})
        end)
    end)
end

return test