class("Rect", DisplayObject) {
    fillColor = new.Color {},
    create = function(self)
        self.view = display.newRect(self.x, self.y, self.width, self.height)
        self.view:setFillColor(self.fillColor.r, self.fillColor.g, self.fillColor.b, self.fillColor.a)
    end
}