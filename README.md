Lua Tools
============

A collection of various scripting tools I have built and used frequently
over the years.

While the repo is named "Lua", these scripts should be run with
[torch7](https://github.com/torch/torch7). Torch injects a lot of
useful globals, like the entire penlight library.

Additionally, each script may require its own dependencies.
Use luarocks as needed ;)

printStatus
-----------

A simple terminal status printer.
It will print a colored, one-line ticker like:

    -- total:   100     --success:  88    --fail:   12

### Usage

```lua
local status = require('printStatus')

-- initialize function
status.init() -- will print the default labels "success" and "fail"

-- init function also takes an optional config.
-- config should be array of tables with label & color fields
-- (total is always prepended to output) e.g.
status.init({
  { label = 'ok', color = 'green' },
  { label = 'bad', color = 'red' }
})

-- update counts and write output
status.update({ ok = 99, bad = 1 })

-- reset the counts, but not the config
status.reset()

-- force a write
status.write()
```
