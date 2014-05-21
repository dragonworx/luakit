class("Gesture") {
    mode = "line",
    new = function(self, args)
        self.target = args.target
        self:rawset("points", {})
    end,
    onStart = function(self, event)
        self:addPoint(event.x, event.y)
    end,
    onMove = function(self, event)
        self:addPoint(event.x, event.y)
    end,
    onEnd = function(self, event)
        self:addPoint(event.x, event.y)
    end,
    addPoint = function(self, x, y)
        local points = self:rawget("points")
        points[#points + 1] = {x, y}
    end,
    get = function(self, k)
        if k == "length" or k == "delta" or k == "direction" or k == "absDelta" or k == "angle" then
            local points = self:rawget("points")
            local startPoint = points[1]
            local endPoint = points[#points]
            local delta = {x = endPoint[1] - startPoint[1], y = endPoint[2] - startPoint[2]}
            if k == "length" then
                return math.sqrt(math.pow(delta.x, 2) + math.pow(delta.y, 2))
            end
            if k == "delta" then
                return delta
            end
            if k == "absDelta" then
                return {math.abs(delta.x), math.abs(delta.y)}
            end
            if k == "direction" then
                local hdir = "left"
                local vdir = "up"
                if delta.x > 0 then hdir = "right" end
                if delta.y > 0 then vdir = "down" end
                return {horizontal = hdir, vertical = vdir}
            end
            if k == "angle" then
                local radians = math.atan2(endPoint[2] - startPoint[2], endPoint[1] - startPoint[1])
                local degrees = radians * 180 / math.pi
                if degrees < 0 then
                    degrees = 180 + (180 - math.abs(degrees))
                end
                return degrees
            end
        end
    end
}