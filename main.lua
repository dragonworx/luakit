require("luakit.ui")
require("luakit.com")

display.setDrawMode("forceRender")

new.Application {
    id = "app",
    new.Image {
        id = "img",
        src = "test.png",
        filter = new.Filter {
            "swirl",
            intensity = 0
        },
        _set = function(self, k, v)
            if k == "fx" then
                self:setFilter("intensity", v, {time = 1000})
                self.alpha = 0
            end
        end,
        new.Transition(),
        enableTouch = true,
        onTouchUp = function(self)
            self.fx = 5
        end
    },
    new.Image {
        width = 200,
        height = 200,
        anchor = "center",
        blendMode = "screen",
        src = "test.png",
        enableTouch = true,
        onTouchUp = function(self, event, gesture)
            self.x = gesture.delta.x
            self.y = gesture.delta.y
            self.rotation = gesture.angle
        end,
        new.Transition {key = "x", delta = true},
        new.Transition {key = "y", delta = true},
        new.Transition {key = "rotation"}
    }
}