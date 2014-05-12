local statusBarHeight = display.statusBarHeight

class("Screen", Container) {
    height = display.contentHeight - statusBarHeight,
}