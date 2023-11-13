# nvim-dap-dotnet

This Neovim plugin took ideas from
[leoluz/nvim-dap-go](https://github.com/leoluz/nvim-dap-go) and was adapted to
fit the use cases in C# .NET debugging. This is an extension of
[nvim-dap](https://github.com/mfussenegger/nvim-dap) and it provides
configurations for launching
[Samsung/netcoredbg](https://github.com/Samsung/netcoredbg).

## Requirements

- [neovim](https://github.com/neovim/neovim) >= 0.9.0
- [Samsung/netcoredbg](https://github.com/Samsung/netcoredbg)
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

## Unit test

To debug unit tests, test process has to be started and wait for the debugger to
attach to it. To do so, the following environment variable has to be set before
start running unit tests.

```sh
export VSTEST_HOST_DEBUG=1
```

This allows `dotnet test` to complete building the source code and start another
process for debugger to attach to it.

```sh
dotnet test
```

(Note that a project can be included in the above command.)

Once the process is ready to be attached by a debugger, text similar to the
following will be shown.

```sh
Starting test execution, please wait...
A total of 1 test files matched the specified pattern.
Host debugging is enabled. Please attach debugger to testhost process to continue.
Process Id: 27081, Name: dotnet
Waiting for debugger attach...
Process Id: 27081, Name: dotnet
```

By this time, we can start debugger and attach to the process (`27081` for the
above example).

Note that a new process will be created by `dotnet test` and the new process
should be attached instead (usually involves command `dotnet exec
--runtimeconfig`).
