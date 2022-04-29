# Awesome wm widget template

## Summary

Put a short, one or two sentences long summary here. It should give people a rough
idea of what this module can be used / what it is useful for.

## Description

Put a longer / more detailed description here if your widget / module needs it. If
you refference a lua type, please link it using one of the macros at the bottom, like so:

```markdown
`foo` is a [`table`][lua-table] which does something.
```

When referring to awesome wm built-in modules, please use an inline link, like so:

```markdown
`bar` is based on [`wibox.widget.imagebox`](https://awesomewm.org/apidoc/widgets/wibox.widget.imagebox.html) and does something else.
```

## Arguments

Arguments are notated in a python-like fassion. Note that lua doesn't allow custom
types (as in: classes as first-*class* types, where a string, number, etc. is treaded
the same as a custom class like a `user`-class for instance), so please do **not** put
names of tables in there. If you have a table `mtb = {...}`, please write
[`table`][lua-table] insead of `mtb`.

```
argument_name: valid_type | other_valid_type = "default_value" -> "valid_value" | { "also_valid" } | { valid_too = 420 } ==> purpose / summary of what the argument does
```

## Examples

 - Do something
```lua
mylib.do_something("foobar")
```
 - Wrap a widget
```lua
local x = mylib.wrap {
	text = "Hello, world!",
	widget = wibox.widget.textbox,
}
```
 - Toast a slice of bread
```lua
-- In Lua, tables are passed by refference, so changing this value from a function
-- will also update the table outside of the function
local bread = {
	toasted = false,
}
mylib.toast_bread(bread)
```

## Refferences / further reading

 - [Awesome window manager API documentation](https://awesomewm.org/apidoc/)

---

## License

 - Code: [Unlicense](https://unlicense.org/)
 - Documentation: [CC0](https://creativecommons.org/publicdomain/zero/1.0/)
 - External resource (like an image or external code): [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)

[lua-nil]: https://www.lua.org/pil/2.1.html
[lua-boolean]: https://www.lua.org/pil/2.2.html
[lua-number]: https://www.lua.org/pil/2.3.html
[lua-string]: https://www.lua.org/pil/2.4.html
[lua-table]: https://www.lua.org/pil/2.5.html
[lua-function]: https://www.lua.org/pil/2.6.html
[lua-userdata-thread]: https://www.lua.org/pil/2.7.html
