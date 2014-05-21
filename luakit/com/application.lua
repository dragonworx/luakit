local statusBarHeight = display.statusBarHeight

class("Application", Group) {
    enableTouch = true,
    new = function(self, args)
        Group.new(self, args)
        self.y = statusBarHeight
        local id = self:rawget("id")
        if id ~= nil then
            _G[id] = self
        end
        self:init()
    end,
    init = function(self)
        Runtime:addEventListener("orientation", function(e)
            display.centerX = display.contentWidth * 0.5
            display.centerY = display.contentHeight * 0.5
            self:doLayout()
        end)
        Group.init(self)
        self.enableTransitions = true
        -- setup touch events
        Runtime:addEventListener("touch", function(event)
            self:onTouch(event)
        end)
    end,
    set = function(self, k, v, ov)
        if k == "enableTouch" then
            return false
        end
        Group.set(self, k, v, ov)
    end,
    get = function(self, k)
        if k == "bounds" then
            return { left = 0, top = statusBarHeight, right = display.contentWidth, bottom = display.contentHeight}
        end
        return Group.get(self, k)
    end,
    getMemoryKb = function(self)
        return collectgarbage("count")
    end,
    gc = function(self)
        collectgarbage()
    end
}