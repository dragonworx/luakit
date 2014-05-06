local statusBarHeight = display.statusBarHeight

class("Screen", Container) {
    y = statusBarHeight,
    height = display.contentHeight - statusBarHeight,
    get = function(self, k)
        if k == "bounds" then
            return {left = 0, top = statusBarHeight, right = display.contentWidth, bottom = display.contentHeight - statusBarHeight}
        end
        if k == "innerView" then return self:rawget("innerView") end
        return Container.get(self, k)
    end,
}