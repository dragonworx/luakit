require("luakit.ui")

local group = new.Screen {
    new.Rect {
        fillColor = Color.red,
        fill = {
            type = "gradient",
            color1 = Color.green:toArray(),
            color2 = Color.red:toArray(),
            direction = "down"
        },
        new.Transition {}
    },
    new.Image {
        id = "img",
        anchor = "center",
        x = display.centerX,
        y = display.centerY,
        src = "test.png",
        new.Transition {delta = true, onComplete = function(self)
            self.rotation = 45
        end},
        blendMode = "screen",
        effect = {
            name = "filter.swirl",
            intensity = 0.4
        }
    },
    new.Transition {},
    new.Text {
        id = "label",
        color = Color.blue,
        text = "Hello world!",
        new.Transition {}
    },
    new.Circle {
        id = "circle",
        fillColor = Color.green,
        x = 0, y = 0,
        radius = 100,
        new.Transition (),
        strokeWidth = 1,
        strokeColor = Color.red:withAlpha(0.1)
    }
}

group.img.rotation = 15
group.width = 300
group.height = 400
group:setWithDelay(1000, "x", 100)
group.label:setWithDelay(1000, "text", "hi there!")
group.label:setWithDelay(1000, "rotation", 50)
group.img:setWithDelay(1000, "src", "me.jpg")
group.circle:setWithDelay(1000, "alpha", 0)