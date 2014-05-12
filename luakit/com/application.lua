local statusBarHeight = display.statusBarHeight

class("Application", Group) {
    new = function(self, args)
        Group.new(self, args)
        self.y = statusBarHeight
        _G["app"] = self
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
    end,
    get = function(self, k)
        if k == "bounds" then
            return { left = 0, top = statusBarHeight, right = display.contentWidth, bottom = display.contentHeight}
        end
        return Group.get(self, k)
    end
}