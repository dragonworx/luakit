class("Transition", Component) {
    key = "*",
    time = 1000,
    easing = "outQuad",
    onComplete = nil,
    delay = 0,
    delta = false,
    new = function(self, args)
        Component.new(self, args)
        if args.onComplete then
            local fn = args.onComplete
            self.onComplete = function()
                fn(self.parent)
            end
        end
    end,
    to = function(self, key, value)
        local k = self.key
        if k == "*" then
            k = key
        end
        local v = value
        if self.delta == true then
            v = self.parent.view[k] + value
        end
        transition.to(self.parent.view, {
            [k] = v,
            time = self.time,
            transition = easing[self.easing],
            delay = self.delay,
            onComplete = self.onComplete
        })
    end
}