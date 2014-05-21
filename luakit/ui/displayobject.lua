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
    blendMode = "normal",
    filter = nil,
    enableTransitions = false,
    enableTouch = false,
    takeFocus = true,
    new = function(self, args)
        self:rawset("transitions", {})
        -- create view
        self:create()
        -- init from args
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
        if args.blendMode then self.blendMode = args.blendMode end
        if args.filter then self.filter = args.filter end
        if args.enableTouch then self.enableTouch = args.enableTouch end
        self.anchor = self.anchor
        -- call super
        Component.new(self, args)
    end,
    swapView = function(self, view)
        -- replace old view with new one
        local ov = self.view
        ov:removeSelf()
        self.view = nil
        -- update group reference
        local parent = self.parent
        if instanceOf(parent, "Group") then
            parent.innerView:insert(view, parent.resetTransform)
        end
        -- update geometry
        self.view = view
        self.anchor = self.anchor
        view.x = ov.x; view.y = ov.y
        view.rotation = ov.rotation
        view.alpha = ov.alpha
        view.blendMode = ov.blendMode
        local filter = self.filter
        if filter then self:applyFilter(filter) end
        view.width = ov.width; view.height = ov.height
        view.visible = ov.visible
        view.xScale = ov.xScale; view.yScale = ov.yScale
    end,
    init = function(self)
        self:doLayout()
    end,
    doLayout = function(self)
        self:performLayout()
        local children = self.children
        for i = 1, #children do
            local child = children[i]
            local doLayout = child.doLayout
            if type(doLayout) == "function" then
                doLayout(child)
            end
        end
    end,
    performLayout = function(self)
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
        return Component.get(self, k)
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
        Component.set(self, k, v, ov)
        if k == "enableTransitions" then
            local children = self.children
            for i = 1, #children do
                local child = children[i]
                if instanceOf(child, "DisplayObject") then
                    children[i].enableTransitions = v
                end
            end
            return
        end
        -- first check for transition, and fire
        if self.enableTransitions == true then
            local transitions = self.transitions
            local trans = transitions["*"] or transitions[k]
            if trans and self:isTransitionKey(k) then
                trans:to(k, v)
                if trans.delta == true then
                    self:rawset(k, self[k] + v)
                    return false
                else
                    return
                end
            end
        end
        if k == "enableTouch" then
            if v == true then
                self:rawset("__onTouch", function(event)
                    return self:onTouch(event)
                end)
                self.view:addEventListener("touch", self:rawget("__onTouch"))
            else
                local onTouch = self:rawget("__onTouch")
                if onTouch ~= nil then
                    self.view:removeEventListener("touch", onTouch)
                end
            end
            return
        end
        -- set properties on view from component
        local marginTop = self.marginTop
        local marginLeft = self.marginLeft
        local view = self.view
        local x = self.x
        local y = self.y
        if k == "anchor" then
            local view = view
            if v == "center" then view.anchorX = 0.5; view.anchorY = 0.5; end
            if v == "topLeft" then view.anchorX = 0; view.anchorY = 0; end
            if v == "topCenter" then view.anchorX = 0.5; view.anchorY = 0; end
            if v == "topRight" then view.anchorX = 1; view.anchorY = 0; end
            if v == "bottomLeft" then view.anchorX = 0; view.anchorY = 1; end
            if v == "bottomCenter" then view.anchorX = 0.5; view.anchorY = 1; end
            if v == "bottomRight" then view.anchorX = 1; view.anchorY = 1; end
            if v == "leftCenter" then view.anchorX = 0; view.anchorY = 0.5; end
            if v == "rightCenter" then view.anchorX = 1; view.anchorY = 0.5; end
            view.x = x + marginLeft
            view.y = y + marginTop
            return
        end
        local marginLeft = marginLeft
        local marginTop = marginTop
        if k == "marginLeft" then
            marginLeft = v
            k = "x"; v = x
        end
        if k == "marginTop" then
            marginTop = v
            k = "y"; v = y
        end
        if k == "x" then
            view.x = v + marginLeft
        end
        if k == "y" then
            view.y = v + marginTop
        end
        if k == "rotation" then
            view.rotation = v
            return
        end
        if k == "scale" then
            view.xScale = v
            view.yScale = v
            return
        end
        if k == "xScale" then
            view.xScale = v
        end
        if k == "yScale" then
            view.yScale = v
        end
        if k == "alpha" then
            view.alpha = v
            return
        end
        if k == "blendMode" then
            view.blendMode = v
        end
        if k == "filter" then
            self:applyFilter(v)
        end
        if k == "width" then
            view.width = v
        end
        if k == "height" then
            view.height = v
        end
        return Component.set(self, k, v, ov)
    end,
    onTouch = function(self, event)
        if event.phase == "began" then
            if self.takeFocus == true then
                display.getCurrentStage():setFocus(self.view)
            end
            local gesture = new.Gesture { target = self }
            self:rawset("__gesture", gesture)
            gesture:onStart(event)
            self:onTouchDown(event, gesture)
        end
        if event.phase == "moved" then
            local gesture = self:rawget("__gesture")
            gesture:onMove(event)
            self:onTouchMove(event, gesture)
        end
        if event.phase == "ended" then
            local gesture = self:rawget("__gesture")
            if gesture then
                gesture:onEnd(event)
            end
            self:onTouchUp(event, gesture)
            if self.takeFocus == true then
                display.getCurrentStage():setFocus(nil)
            end
            self:rawset("__gesture", nil)
        end
        if self.takeFocus == true then
            return true
        end
    end,
    onTouchDown = function(self, event, gesture)

    end,
    onTouchMove = function(self, event, gesture)

    end,
    onTouchUp = function(self, event, gesture)

    end,
    applyFilter = function(self, filter)
        filter:applyTo(self.view)
    end,
    setFilter = function(self, key, value, trans)
        self.filter:setValue(key, value, self.view, trans)
    end,
    dispose = function(self)
        self.view:removeSelf()
        self.view = nil
        -- remove touch listener
        if self:rawget("__onTouch") ~= nil then
            self:rawset("__onTouch", nil)
        end
        Component.dispose(self)
    end
}