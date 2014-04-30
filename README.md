##Lua - Kit - The 3 pillars of any good app

Lua-Kit is a collection of 3 essential libraries for Lua development.

- **console** a powerful replacement for print(), writes multiple arguments in full detail, groups, level indentation, and more!
- **expect** a simple BDD-style unit testing framework inspired from expect.js
- **class** Real classes that can inherit, override, and call super methods at any level. Also supports onChange events to detect changes and override setters.

####Usage

Simply add the *luakit* folder to your Lua application and call `require("luakit.inc")` to include all modules.

Refer to each modules test* function for usage and details.

####Tests

Each module returns a main testing function. Just call the returning value `require("luakit.console")()` to execute the module test.