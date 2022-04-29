# Kill all but one

## Summary

A simple script that kills all processes matching a pattern, except for one.

## Description

This module is useful if you have problems with the same application running multiple times.
While it is typically better to try to fix the script / code that runs it multiple times,
in some edge cases, it may not be viable.

## Arguments

```
pattern: string ==> A regular expression that matches a running PID
```

## Examples

 - Kill all but the first running instances of `pasystray`
```lua
-- Note: "^pattern$" will only return exact matches, so if "pasystrayer" were to be running,
-- it would not be counted (and, thus, not be killed).
kill_all_but_one {
	pattern = "^pasystray$"
}
```

## Refferences / further reading

 - [Awesome - Module: awful.spawn](https://awesomewm.org/apidoc/libraries/awful.spawn.html)
 - [`pgrep(1)` - Linux man page](https://linux.die.net/man/1/pgrep)
 - [`kill(1)` - Linux man page](https://linux.die.net/man/1/kill)

---

## License

 - Code: [Unlicense](https://unlicense.org/)
 - Documentation: [CC0](https://creativecommons.org/publicdomain/zero/1.0/)

[lua-nil]: https://www.lua.org/pil/2.1.html
[lua-boolean]: https://www.lua.org/pil/2.2.html
[lua-number]: https://www.lua.org/pil/2.3.html
[lua-string]: https://www.lua.org/pil/2.4.html
[lua-table]: https://www.lua.org/pil/2.5.html
[lua-function]: https://www.lua.org/pil/2.6.html
[lua-userdata-thread]: https://www.lua.org/pil/2.7.html
