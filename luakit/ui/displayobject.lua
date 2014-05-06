class("DisplayObject", Component) {
    x = 0,
    y = 0,
    width = display.contentWidth,
    height = display.contentHeight,
    rotation = 0,
    xScale = 1,
    yScale = 1,
    alpha = 1,
    visible = true,
    anchor = "topLeft",
    marginLeft = 0,
    marginTop = 0,
    view = nil,
    transitions = nil,
    new = function(self, args)
        self:rawset("transitions", {})
        -- create view
        self:create()
        -- set properties from constructor args
        self.anchor = self.anchor
        if args.x then self.x = args.x end
        if args.y then self.y = args.y end
        if args.rotation then self.rotation = args.rotation end
        if args.alpha then self.alpha = args.alpha end
        if args.width then self.width = args.width end
        if args.height then self.height = args.height end
        if args.visible then self.visible = args.visible end
        if args.scale then self.scale = args.scale end
        if args.xScale then self.xScale = args.xScale end
        if args.yScale then self.yScale = args.yScale end
        -- call super
        Component.new(self, args)
    end,
    swapView = function(self, view)
        local ov = self.view
        ov:removeSelf()
        self.view = nil
        self.view = view
        self.anchor = self.anchor
        view.rotation = ov.rotation
        view.alpha = ov.alpha
        view.width = ov.width; view.height = ov.height
        view.visible = ov.visible
        view.xScale = ov.xScale; view.yScale = ov.yScale
        if instanceOf(self.parent, "Group") then
            self.parent.view:insert(self.view, self.parent.resetTransform)
        end
    end,
    addChild = function(self, child)
        if instanceOf(child, "Transition") then
            self.transitions[child.key] = child
        end
        Component.addChild(self, child)
    end,
    create = function(self)
        self.view = display.newGroup()
    end,
    get = function(self, k)
        if k == "bounds" then
            local r = self.view.contentBounds
            return {left = r.xMin, top = r.yMin, right = r.xMax, bottom = r.yMax}
        end
    end,
    isTransitionKey = function(self, k)
        return k == "x"
            or k == "y"
            or k == "width"
            or k == "height"
            or k == "rotation"
            or k == "alpha"
            or k == "xScale"
            or k == "yScale"
    end,
    set = function(self, k, v, ov)
        -- first check for transition
        local trans = self.transitions["*"] or self.transitions[k]
        if trans and self:isTransitionKey(k) then
            trans:to(k, v)
            return
        end
        -- set properties on view from component
        if k == "anchor" then
            local view = self.view
            if v == "center" then view.anchorX = 0.5; view.anchorY = 0.5; end
            if v == "topLeft" then view.anchorX = 0; view.anchorY = 0; end
            if v == "topCenter" then view.anchorX = 0.5; view.anchorY = 0; end
            if v == "topRight" then view.anchorX = 1; view.anchorY = 0; end
            if v == "bottomLeft" then view.anchorX = 0; view.anchorY = 1; end
            if v == "bottomCenter" then view.anchorX = 0.5; view.anchorY = 1; end
            if v == "bottomRight" then view.anchorX = 1; view.anchorY = 1; end
            if v == "leftCenter" then view.anchorX = 0; view.anchorY = 0.5; end
            if v == "rightCenter" then view.anchorX = 1; view.anchorY = 0.5; end
            view.x = self.x + self.marginLeft
            view.y = self.y + self.marginTop
            return
        end
        local marginLeft = self.marginLeft
        local marginTop = self.marginTop
        if k == "marginLeft" then
            marginLeft = v
            k = "x"; v = self.x
        end
        if k == "marginTop" then
            marginTop = v
            k = "y"; v = self.y
        end
        if k == "x" then
            self.view.x = v + marginLeft
        end
        if k == "y" then
            self.view.y = v + marginTop
        end
        if k == "rotation" then
            self.view.rotation = v
            return
        end
        if k == "scale" then
            self.view.xScale = v
            self.view.yScale = v
            return
        end
        if k == "xScale" then
            self.view.xScale = v
        end
        if k == "yScale" then
            self.view.yScale = v
        end
        if k == "alpha" then
            self.view.alpha = v
            return
        end
        if k == "width" then
            self.view.width = v
        end
        if k == "height" then
            self.view.height = v
        end
    end,
    dispose = function(self)
        self.view:removeSelf()
        self.view = nil
        Component.dispose(self)
    end
}