local statusBarHeight = display.statusBarHeight

class("Screen", Container) {
    align = "topLeft",
    x = 0,
    y = statusBarHeight,
    height = display.actualContentHeight - statusBarHeight,
    create = function(self)
        Container.create(self)
        local innerView = display.newGroup()
        innerView.anchorX = 0; innerView.anchorY = 0
        innerView.x = display.actualContentWidth * -0.5
        innerView.y = Screen.height * -0.5
        self:rawset("innerView", innerView)
        self.view:insert(innerView)
    end,
    get = function(self, k)
        if k == "bounds" then
            return {left = 0, top = statusBarHeight, right = display.actualContentWidth, bottom = display.actualContentHeight - statusBarHeight}
        end
        return DisplayObject.get(self, k)
    end,
}