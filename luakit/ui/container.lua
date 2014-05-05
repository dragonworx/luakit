class("Container", Group) {
    x = display.actualContentWidth * 0.5,
    y = display.actualContentHeight * 0.5,
    create = function(self)
        self.view = display.newContainer(self.width, self.height)
    end
}