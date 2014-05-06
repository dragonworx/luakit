require("luakit.ui")

local group = new.Screen {
    new.Rect {
        fillColor = Color.red
    },
    new.Image {
        id = "img",
        anchor = "center",
        x = display.centerX,
        y = display.centerY,
        src = "test.png",
        new.Transition {delta = true, onComplete = function(self)
            self.rotation = 45
        end}
    },
    new.Transition {},
    new.Text {
        id = "label",
        color = Color.blue,
        text = "Hello world!"
    }
}

group.img.rotation = 15
group.width = 300
group.height = 400
group:setWithDelay(1000, "x", 100)
group.label:setWithDelay(1000, "text", "hi there!")
--group.label:setWithDelay(1000, "fontSize", 10)
--group.img:setWithDelay(1000, "src", "me.jpg")