class("Shape", DisplayObject) {
    fillColor = new.Color {},
    strokeColor = new.Color {},
    strokeWidth = 0,
    fill = nil,
    new = function(self, args)
        DisplayObject.new(self, args)
        if args.fill then self.fill = args.fill end
    end,
    create = function(self)
        local fillColor = self.fillColor
        local strokeColor = self.strokeColor
        self.view:setFillColor(fillColor.r, fillColor.g, fillColor.b, fillColor.a)
        self.view:setStrokeColor(strokeColor.r, strokeColor.g, strokeColor.b, strokeColor.a)
        self.view.strokeWidth = self.strokeWidth
    end,
    set = function(self, k, v, ov)
        if k == "strokeColor" then
            self.view:setStrokeColor(v.r, v.g, v.b, v.a)
        end
        if k == "strokeWidth" then
            self.view.strokeWidth = v
        end
        if k == "fillColor" then
            self.view:setFillColor(v.r, v.g, v.b, v.a)
        end
        if k == "fill" then
            self.view.fill = v
        end
        return DisplayObject.set(self, k, v, ov)
    end,
    swapView = function(self, view)
        local ov = self.view
        DisplayObject.swapView(self, view)
        view.strokeWidth = ov.strokeWidth
        view:setFillColor(self.fillColor.r, self.fillColor.g, self.fillColor.b, self.fillColor.a)
        view:setStrokeColor(self.strokeColor.r, self.strokeColor.g, self.strokeColor.b, self.strokeColor.a)
    end
}