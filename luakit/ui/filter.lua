local function isArrayTable(t)
    local intKeys = 0
    for k, v in pairs(t) do
        if type(k) == "number" then intKeys = intKeys + 1 end
    end
    return #t == intKeys
end

local function applyTo(viewObj, t)
    for k, v in pairs(t) do
        if type(v) == "table" and not isArrayTable(v) then
            applyTo(viewObj[k], v)
        else
            viewObj[k] = v
        end
    end
end

class("Filter") {
    effect = null,
    properties = {},
    new = function(self, args)
        for k, v in pairs(args) do
            if type(k) == "number" and type(v) == "string" then
                self.effect = v
            else
                self.properties[k] = v
            end
        end
        self.defaults = clone(self.properties)
    end,
    applyTo = function(self, view)
        view.fill.effect = "filter." .. self.effect
        applyTo(view.fill.effect, self.properties)
    end,
    setValue = function(self, key, value, view, trans)
        local obj = self.properties
        local viewObj = view.fill.effect
        local isTransition = type(trans) == "table"
        for k in string.gmatch(key, "[^.]+") do
            if type(obj[k]) == "number" then
                obj[k] = value
                if isTransition then
                    transition.to(viewObj, {time = trans.time, [k] = value, onComplete = trans.onComplete})
                else
                    viewObj[k] = value
                end
            end
            obj = obj[k]
            viewObj = viewObj[k]
        end
    end,
    reset = function(self)
        self.properties = clone(self.defaults)
    end
}