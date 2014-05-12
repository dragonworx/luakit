function Button(options)
    return new.Group {
        _set = function(self, k, v, ov)
            if k == "text" then self.label.text = v end
            if k == "width" then self.rect.width = v end
        end,
        _get = function(self, k)
            if k == "foo" then return self.label.text end
        end,
        new.Rect {
            id = "rect",
            width = options.width,
            height = options.height,
            fillColor = Color.red,
            new.Transition {},
            _init = function(self)
                print("rect")
            end
        },
        new.Text {
            id = "label",
            text = options.text,
            _init = function(self)
                print("text")
            end
        },
        onEvent = function(self, type, data)
            print(type)
        end,
        _init = function(self)
            print("button")
        end
    }
end