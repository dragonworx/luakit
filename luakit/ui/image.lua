class("Image", DisplayObject) {
    src = nil,
    create = function(self)
        self.view = display.newImage(self.src)
        if self.view == nil then
            error("Image src not found - \"" .. self.src .. "\"")
        end
    end,
    set = function(self, k, v, ov)
        if k == "src" then
            self:swapView(display.newImage(v))
        end
        return DisplayObject.set(self, k, v, ov)
    end
}