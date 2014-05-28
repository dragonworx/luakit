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
        Runtime:addEventListener("touch", function(event)
            self:onTouch(event)
        end)
        Runtime:addEventListener("orientation", function(e)
            display.centerX = display.contentWidth * 0.5
            display.centerY = display.contentHeight * 0.5
            self:doLayout()
        end)
        Group.init(self)
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