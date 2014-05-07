class("Color") {
    r = 1,
    g = 1,
    b = 1,
    a = 1,
    toArray = function(self)
        return {self.r, self.g, self.b, self.a}
    end,
    withAlpha = function(self, a)
        return new.Color {
            r = self.r,
            g = self.g,
            b = self.g,
            a = a
        }
    end
}

Color.red = new.Color {r = 1, g = 0, b = 0}
Color.green = new.Color {r = 0, g = 1, b = 0}
Color.blue = new.Color {r = 0, g = 0, b = 1}
Color.white = new.Color {r = 1, g = 1, b = 1}
Color.black = new.Color {r = 0, g = 0, b = 0}
Color.lightGrey = new.Color {r = 0.65, g = 0.65, b = 0.65}
Color.darkGrey = new.Color {r = 0.35, g = 0.35, b = 0.35}