class("Text", DisplayObject) {
    text = "",
    font = native.systemFont,
    fontSize = display.actualContentHeight * 0.05,
    alignment = "center",
    color = new.Color {},
    width = 0,
    create = function(self)
        self.view = display.newText {
            text = self.text,
            x = self.x,
            y = self.y,
            width = self.width,
            font = self.font,
            fontSize = self.fontSize,
            align = self.alignment
        }
        self.view:setFillColor(self.color.r, self.color.g, self.color.b, self.color.a)
    end,
    get = function(self, k)
        if k == "width" and self:rawget("width") == 0 then return nil end
    end
}