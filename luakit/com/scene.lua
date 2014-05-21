class("Scene", Component) {
    hasCreated = false,
    isActive = false,
    show = function(self)
        if not self.isActive then
            self:onBeforeShow()
            self:appear()
            self.isActive = true
            self:onAfterShow()
        end
    end,
    onBeforeShow = function(self)
    end,
    appear = function(self)
    end,
    onAfterShow = function(self)
    end
}

Scene.goto = function(id)

end