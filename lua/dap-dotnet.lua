local M = {
}

local function get_netcoredbg_path()
	local netcoredbg_path = vim.fn.getenv("HOME") .. "/.local/share/nvim/mason/packages/" .. "netcoredbg/netcoredbg"
	if vim.fn.filereadable(netcoredbg_path) == 1 then
		return netcoredbg_path
	end
	return "/usr/local/netcoredbg"
end

local default_config = {
	coreclr = {
		netcoredbg_path = get_netcoredbg_path(),
		args = { '--interpreter=vscode' },
	},
}

local function load_module(module_name)
	local ok, module = pcall(require, module_name)
	assert(ok, string.format("dap-dotnet dependency error: %s not installed", module_name))
	return module
end

local function get_dll()
	local i = 0
	local j = 0
	local directories = {}
	local dll_files = {}
	local popen = io.popen
	local find_directory_command = 'find . -type d -depth 1 -not -path "*/.*"'
	local pfile = popen(find_directory_command)
	if pfile then
		for filename in pfile:lines() do
			i = i + 1
			directories[i] = filename
		end
		pfile:close()
	end

	local co = coroutine.running()
	if co then
		return coroutine.create(function()
			vim.ui.select(directories, { prompt = "Select a project directory" }, function(selected_directory)
				local debug_directory = vim.fn.getcwd() .. string.gsub(selected_directory, "./", "/") .. "/bin/Debug"
				local find_dll_command = 'find ' .. debug_directory .. ' -type f -name "*.dll"'
				local dll_file = popen(find_dll_command)
				if dll_file then
					for filename in dll_file:lines() do
						j = j + 1
						local escaped_debug_directory = string.gsub(debug_directory, "%-", "%%-")
						dll_files[j] = string.gsub(filename, escaped_debug_directory, "")
					end
					dll_file:close()
				end
				vim.ui.select(dll_files, { prompt = "Select a DLL file" }, function(selected_dll)
					coroutine.resume(co, debug_directory .. selected_dll)
				end)
			end)
		end)
	else
		vim.ui.select(directories, { prompt = "Select a project directory" }, function(selected_directory)
			local debug_directory = vim.fn.getcwd() .. string.gsub(selected_directory, "./", "/") .. "/bin/Debug"
			local find_dll_command = 'find ' .. debug_directory .. ' -type f -name "*.dll"'
			local dll_file = popen(find_dll_command)
			if dll_file then
				for filename in dll_file:lines() do
					j = j + 1
					local escaped_debug_directory = string.gsub(debug_directory, "%-", "%%-")
					dll_files[j] = string.gsub(filename, escaped_debug_directory, "")
				end
				dll_file:close()
			end
			vim.ui.select(dll_files, { prompt = "Select a DLL file" }, function(selected_dll)
				coroutine.resume(co, debug_directory .. selected_dll)
			end)
		end)
	end
end

local function get_arguments()
  local co = coroutine.running()
  if co then
    return coroutine.create(function()
      local args = {}
      vim.ui.input({ prompt = "Args: " }, function(input)
        args = vim.split(input or "", " ")
      end)
      coroutine.resume(co, args)
    end)
  else
    local args = {}
    vim.ui.input({ prompt = "Args: " }, function(input)
      args = vim.split(input or "", " ")
    end)
    return args
  end
end

local function filtered_pick_process()
	local opts = {}
	vim.ui.input(
		{ prompt = "Search by process name (lua pattern), or hit enter to select from the process list: " },
		function(input)
			opts["filter"] = input or ""
		end
	)
	return require("dap.utils").pick_process(opts)
end

local function setup_adapter(dap, config)
	dap.adapters.coreclr = {
		type = "executable",
		command = config.coreclr.netcoredbg_path,
		args = config.coreclr.args,
	}
end

local function setup_configurations(dap, configs)
	dap.configurations.cs = {
		{
			type = "coreclr",
			name = "[dap-dotnet] Launch",
			request = "launch",
			-- preLaunchTask = "build",
			program = get_dll,
			args = {},
			cwd = "${workspaceFolder}",
			stopAtEntry = false,
			env = {
				ASPNETCORE_ENVIRONMENT = "Development",
			},
		},
		{
			type = "coreclr",
			name = "[dap-dotnet] Launch with arguments",
			request = "launch",
			-- preLaunchTask = "build",
			program = get_dll,
			args = get_arguments,
			cwd = "${workspaceFolder}",
			stopAtEntry = false,
			env = {
				ASPNETCORE_ENVIRONMENT = "Development",
			},
		},
		{
			type = "coreclr",
			name = "[dap-dotnet] Attach",
			request = "attach",
			processId = filtered_pick_process,
		},
	}

	if configs == nil or configs.dap_configurations == nil then
		return
	end

	for _, config in ipairs(configs.dap_configurations) do
		if config.type == "cs" then
			table.insert(dap.configurations.cs, config)
		end
	end
end

function M.setup(opts)
	local config = vim.tbl_deep_extend("force", default_config, opts or {})
	local dap = load_module("dap")
	setup_adapter(dap, config)
	setup_configurations(dap, config)
end

return M
