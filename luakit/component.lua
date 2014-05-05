class("Component") {
    new = function(self, args)
        self.listeners = {}
        self.children = {}
        for i = 1, #args do
            local child = args[i]
            if instanceOf(child, "Component") then
                self:addChild(child)
            end
        end
    end,
    addEventListener = function(self, eventType, listener, handlerName)
        local bindings = self.listeners[eventType]
        if bindings == nil then
            bindings = {}
            self.listeners[eventType] = bindings
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
    end,
    addChild = function(self, child)
        self.children[#self.children + 1] = child
        child.parent = self
        if child.id then
            self[child.id] = child
        end
    end,
    removeChild = function(self, child)
        table.remove(self.children, table.indexOf(self.children, child))
        child.parent = nil
        if child.id then
            self[child.id] = nil
        end
    end,
    setWithDelay = function(self, delay, k, v)
        timer.performWithDelay(delay, function()
            self[k] = v
        end)
    end,
    dispose = function(self)
        -- remove listeners
        for eventType, bindings in pairs(self.listeners) do
            for i = 1, #bindings do
                local binding = bindings[i]
                binding.listener = nil
                table.remove(bindings, i)
            end
            self.listeners[eventType] = nil
        end
        -- remove children
        for i = 1, #self.children do
            self.children[i]:dispose()
            self.children[i] = nil
        end
        -- dettach parent
        self.parent = nil
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