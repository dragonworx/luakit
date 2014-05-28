require("luakit.ui")
require("luakit.com")

display.setDrawMode("forceRender")

local filters = {
    new.Filter {
        "pixelate",
        numPixels = 1
    },
    new.Filter {
        "radialWipe",
        center = { 0.5, 0.5 },
        smoothness = 1,
        axisOrientation = 0,
        progress = 0
    },
    new.Filter {
        "iris",
        center = { 0.5, 0.5 },
        aperture = 0,
        aspectRatio = 388 / 355,
        smoothness = 0.5
    },
    new.Filter {
        "polkaDots",
        numPixels = 16,
        dotRadius = 1,
        aspectRatio = 388 / 355
    },
    new.Filter {
        "swirl",
        intensity = 0
    },
    new.Filter {
        "blurGaussian",
        horizontal = {
            blurSize = 0,
            sigma = 140
        },
        vertical = {
            blurSize = 0,
            sigma = 140
        }
    },
    new.Filter {
        "vignette",
        radius = 1
    },
    new.Filter {
        "zoomBlur",
        u = 0.5,
        v = 0.5,
        intensity = 0
    },
    new.Filter {
        "exposure",
        exposure = 0
    },
    new.Filter {
        "bulge",
        intensity = 1
    },
    new.Filter {
        "crystallize",
        numTiles = 100
    }
}
local filterMorphs = {
    pixelate = {
        {"numPixels", 20}
    },
    radialWipe = {
        {"progress", 1}
    },
    iris = {
        {"aperture", 1}
    },
    polkaDots = {
        {"numPixels", 50},
        {"dotRadius", 3}
    },
    swirl = {
        {"intensity", 5}
    },
    blurGaussian = {
        {"horizontal.blurSize", 100},
        {"vertical.blurSize", 100},
    },
    vignette = {
        {"radius", -2}
    },
    zoomBlur = {
        {"intensity", 10}
    },
    exposure = {
        {"exposure", 2}
    },
    bulge = {
        {"intensity", 5}
    },
    crystallize = {
        {"numTiles", 1}
    }
}
local filterIndex = 0
local function nextFilter()
    filterIndex = filterIndex + 1
    if filterIndex > #filters then filterIndex = 1 end
    local filter = filters[filterIndex]
    filter:reset()
    app.txt.text = filter.effect
    return filter
end

local id = 0
function newImage(filter, dec)
    if dec == true then
        id = id - 1
    else
        id = id + 1
    end
    return new.Image {
        id = "image",
        isAnimating = false,
        anchor = "topCenter",
        x = display.centerX,
        src = "test.png",
        filter = nextFilter(),
        _set = function(self, k, v, ov)
            if k == "fx" then
                for i, morph in ipairs(filterMorphs[self.filter.effect]) do
                    self:setFilter(morph[1], morph[2], {time = 1000, onComplete = function()
                        self.alpha = 0
                        self.isAnimating = true
                    end})
                end
            end
        end,
        new.Transition {key = "alpha", time = 300, transition = easing.outQuart, onComplete = function(self)
            nextImage()
        end},
        enableTouch = true,
        onTouchUp = function(self, event, gesture)
            if not self.isAnimating then
                self.fx = 5
            end
        end
    }
end

function nextImage()
    app.group.image:dispose()
    app.group:addChild(newImage())
end

new.Application {
    id = "app",
    _init = function(self)
        self.group:addChild(newImage())
    end,
    new.Group {
        anchor = "topCenter",
        id = "group"
    },
    new.Text {
        id = "txt",
        anchor = "center",
        x = display.centerX,
        y = 400
    },
    new.Image {
        width = 200,
        height = 200,
        x = display.centerX,
        y = display.centerY,
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
        new.Transition {key = "rotation"},
        filter = new.Filter {
            "wobble",
            amplitude = 20
        }
    },
    new.Scene {
        id = "scene1",
        x = 200,
        construct = function(self)
            self:addChild(new.Rect {
                fillColor = Color.red,
                width = 100,
                height = 100
            })
        end
    },
    new.Scene {
        id = "scene2",
        construct = function(self)
            self:addChild(new.Rect {
                fillColor = Color.green,
                width = 100,
                height = 100
            })
        end
    }
}

Scene.goto("scene2")
timer.performWithDelay(2000, function()
    Scene.goto("scene1")
end)