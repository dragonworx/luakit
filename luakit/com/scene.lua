local scenes = {}

class("Scene", Group) {
    hasCreated = false,
    isActive = false,
    new = function(self, args)
        Group.new(self, args)
        scenes[self.id] = self
    end,
    show = function(self, currentScene)
        if not self.isActive then
            if not self.hasCreated then
                self:construct()
            end
            self:onBeforeShow(currentScene)
            self:transitionIn(currentScene)
            self.isActive = true
            self:onAfterShow(currentScene)
        end
    end,
    onBeforeShow = function(self)
    end,
    transitionIn = function(self)
        self.visible = true
    end,
    onAfterShow = function(self)
    end,
    hide = function(self, newScene)
        if self.isActive then
            self:onBeforeHide(newScene)
            self:transitionOut(newScene)
            self.isActive = false
            self:onAfterHide(newScene)
        end
    end,
    onBeforeHide = function(self)
    end,
    transitionOut = function(self)
        self.visible = false
    end,
    onAfterHide = function(self)
    end
}

local sceneStack = {}
Scene.goto = function(id, overlay)
    local newScene = scenes[id]
    local currentScene = sceneStack[#sceneStack]
    if overlay ~= true and #sceneStack > 0 then
        table.remove(sceneStack, #sceneStack)
        currentScene:hide(newScene)
    end
    table.insert(sceneStack, newScene)
    newScene:show(currentScene)
end