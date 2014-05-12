class("PinLayout", Layout) {
    performLayout = function(self)
        local children = self.children
        local bounds = self.parent.bounds
        local width = bounds.right - bounds.left
        local height = bounds.bottom - bounds.top
        for i = 1, #children do
            local child = children[i]
            local layout = child.layout
            if layout ~= nil then
                local x = layout.x
                local y = layout.y
                local w = layout.width
                local h = layout.height
                if x ~= nil then
                    child.x = width * x
                end
                if y ~= nil then
                    child.y = height * y
                end
                if w ~= nil then
                    child.width = width * w
                end
                if h ~= nil then
                    child.height = height * h
                end
            end
        end
    end
}