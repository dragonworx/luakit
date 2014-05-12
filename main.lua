require("luakit.ui")
require("luakit.com")

new.Application {
    new.PinLayout {
        new.Image {
            new.Transition {time = 250},
            anchor = "center",
            layout = {
                x = 0.5,
                y = 0.5,
                width = 1,
                height = 1
            },
            src = "debug.png",
            width = 320,
            height = 480 - display.statusBarHeight
        }
    },
    new.Text {
        id = "txt"
    },
}
timer.performWithDelay(100, function()
    local kb = collectgarbage("count")
    txt.text = kb
end, 0)

Runtime:addEventListener("tap", function(e)
    collectgarbage()
end)