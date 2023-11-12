# nvim-dap-dotnet

This Neovim plugin took ideas from
[leoluz/nvim-dap-go](https://github.com/leoluz/nvim-dap-go) and adapt it to fit
use cases in C# .NET debugging. This is an extension of
[nvim-dap](https://github.com/mfussenegger/nvim-dap) and it provides
configurations for launching
[Samsung/netcoredbg](https://github.com/mfussenegger/nvim-dap).

## Requirements

- [neovim] >= 0.9.0
- [Samsung/netcoredbg](https://github.com/mfussenegger/nvim-dap)
  - for any non-Apple-silicon machines, it is recommend to install it via
    [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim)
  - for Apple-silicon machines, you may need to follow [compilation
    steps](https://github.com/Samsung/netcoredbg#compiling-1) and install it to
    path `/usr/local/netcoredbg`.

## Configuration

```lua
local dotnet = require("dap-dotnet")
dotnet.setup()
```
