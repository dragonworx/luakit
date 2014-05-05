require("luakit.ui")

local g = new.Screen {
    id = "g",
    new.Rect {
        align = "topCenter",
        x = display.centerX,
        y = 0
    },
    new.Image {
        x = display.centerX,
        y = display.centerY,
        id = "img",
        src = "test.png",
        new.Transition {delta = true, onComplete = function(self)
        self.rotation = 45
        end}
    },
    new.Transition {},
    new.Text {
        color = Color.blue,
        text = "Hello world!",
        align = "topLeft"
    }
}

g.img.rotation = 45
--g.height = 200