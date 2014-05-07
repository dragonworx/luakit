class("Rect", Shape) {
    create = function(self)
        self.view = display.newRect(self.x, self.y, self.width, self.height)
        Shape.create(self)
    end
}