class("RoundedRect", Shape) {
    radius = 0,
    create = function(self)
        self.view = display.newRoundedRect(self.x, self.y, self.width, self.height, self.radius)
        Shape.create(self)
    end,
    set = function(self, k, v, ov)
        if k == "radius" then
            self.view.path.radius = v
        end
        Shape.set(self, k, v, ov)
    end
}