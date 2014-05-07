class("Container", Group) {
    create = function(self)
        self.view = display.newContainer(self.width, self.height)
        local innerView = display.newGroup()
        innerView.x = display.contentWidth * -0.5
        innerView.y = self.height * -0.5
        self:rawset("innerView", innerView)
        self.view:insert(innerView)
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
        Group.set(self, k, v, ov)
    end
}