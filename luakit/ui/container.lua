class("Container", Group) {
    create = function(self)
        local view = display.newContainer(self.width, self.height)
        local innerView = display.newGroup()
        view.anchorX = 0
        view.anchorY = 0
        innerView.x = self.width * -0.5
        innerView.y = self.height * -0.5
        view:insert(innerView)
        self:rawset("view", view)
        self:rawset("innerView", innerView)
    end,
    set = function(self, k, v, ov)
        if k == "width" or k == "height" then
            local delta = ov - v
            local innerView = self:rawget("innerView")
            local trans = self.transitions["*"] or self.transitions[k]
            local key = "x"
            if k == "height" then key = "y" end
            if trans and self:isTransitionKey(k) then
                transition.to(innerView, {
                    [key] = innerView[key] + delta * 0.5,
                    time = trans.time,
                    transition = easing[trans.easing],
                    delay = trans.delay
                })
            else
                innerView[key] = innerView[key] + delta * 0.5
            end
        end
        return Group.set(self, k, v, ov)
    end,
    get = function(self, k)
        if k == "innerView" then
            return self:rawget("innerView")
        end
        if k == "bounds" then
            return {left = self.x, top = self.y, right = self.x + self.width, bottom = self.y + self.height}
        end
        return Group.get(self, k)
    end,
}