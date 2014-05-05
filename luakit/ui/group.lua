local function addChildrenToGroup(children, group)
    for i = 1, #children do
        local child = children[i]
        if instanceOf(child, "DisplayObject") then
            group:insert(child.view)
            if instanceOf(child, "Group") == false then
                addChildrenToGroup(child.children, group)
            end
        end
    end
end

class("Group", DisplayObject) {
    resetTransform = false,
    addChild = function(self, child)
        DisplayObject.addChild(self, child)
        if instanceOf(child, "DisplayObject") then
            self.innerView:insert(child.view, self.resetTransform)
        end
    end,
    removeChild = function(self, child)
        DisplayObject.addChild(self, child)
        if instanceOf(child, "DisplayObject") then
            self.innerView:remove(child.view)
        end
    end,
    get = function(self, k)
        if k == "innerView" then return self.view end
        return DisplayObject.get(self, k)
    end
}