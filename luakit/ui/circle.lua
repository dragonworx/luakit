class("Circle", Shape) {
    radius = 100,
    create = function(self)
        self.view = display.newCircle(self.x, self.y, self.radius)
        Shape.create(self)
    end,
    set = function(self, k, v, ov)
        if k == "radius" then
            self.view.path.radius = v
        end
        Shape.set(self, k, v, ov)
    end
}