class("Image", DisplayObject) {
    src = nil,
    create = function(self)
        self.view = display.newImage(self.src)
        if self.view == nil then
            error("Image src not found - \"" .. self.src .. "\"")
        end
    end
}