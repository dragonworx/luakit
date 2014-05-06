class("Text", DisplayObject) {
    text = "",
    font = native.systemFont,
    fontSize = display.contentHeight * 0.05,
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
            align = self.align
        }
        self.view:setFillColor(self.color.r, self.color.g, self.color.b, self.color.a)
    end,
    set = function(self, k, v, ov)
        if k == "text" then self.view.text = v end
        if k == "font" or k == "fontSize" or k == "width" or k == "align" then
            self:swapView(display.newText {
                text = self.text,
                x = self.x,
                y = self.y,
                width = self.width,
                font = self.font,
                fontSize = self.fontSize,
                align = self.align
            })
        end
        DisplayObject.set(self, k, v, ov)
    end,
    get = function(self, k)
        if k == "width" and self:rawget("width") == 0 then return nil end
    end
}