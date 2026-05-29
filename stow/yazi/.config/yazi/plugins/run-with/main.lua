ya.notify({ title = "Debug", content = "Plugin Loaded!", timeout = 3, level = "info" })

local shell = os.getenv("SHELL") or "bash"

-- 1. Helper to notify on errors
local fail = function(s, ...)
	ya.notify({ title = "Run With", content = string.format(s, ...), timeout = 5, level = "error" })
end

-- 2. Sync function to get currently selected files from Yazi's state
local get_selected = ya.sync(function()
	local tab = cx.active
	local paths = {}

	-- Iterate over selected files
	for _, url in pairs(tab.selected) do
		table.insert(paths, tostring(url))
	end

	-- If nothing selected, use the hovered file
	if #paths == 0 and tab.current.hovered then
		table.insert(paths, tostring(tab.current.hovered.url))
	end

	return paths
end)

local function entry()
	-- 3. Hide Yazi UI to allow FZF/Interactive apps to render
	local _permit = ui.hide()

	-- 4. Get the files we want to operate on
	local files = get_selected()
	if #files == 0 then
		return fail("No files selected")
	end

	-- 5. Prepare the command to find binaries
	-- We use the find logic you provided, wrapped in bash to ensure pipe/env support
	local list_cmd = [[
		find $(echo $PATH | tr ":" " ") -maxdepth 1 -type f -perm -111 2>/dev/null | xargs -n 1 basename | sort -u | fzf --prompt="Run Binary: "
	]]

	-- 6. Spawn the shell to run FZF
	local child, err = Command(shell)
		:arg("-c")
		:arg(list_cmd)
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:stderr(Command.INHERIT)
		:spawn()

	if not child then
		return fail("Failed to spawn fzf: %s", err)
	end

	-- 7. Wait for user selection
	local output, err = child:wait_with_output()

	if not output then
		return fail("Cannot read output: %s", err)
	elseif output.status.code ~= 0 then
		return -- User cancelled (Ctrl-C or Esc)
	end

	-- 8. Clean up the binary name (remove newlines)
	local target_binary = output.stdout:gsub("[\r\n]+$", "")

	if target_binary == "" then
		return
	end

	-- 9. Execute the selected binary with the selected files
	-- We use Command() again so arguments (filenames with spaces) are handled safely
	local run_cmd = Command(target_binary)
	
	-- Add all selected files as arguments
	for _, file in ipairs(files) do
		run_cmd:arg(file)
	end

	-- Connect IO so interactive programs (vim, nano) work, and CLI tools print to screen
	local run_child, run_err = run_cmd
		:stdin(Command.INHERIT)
		:stdout(Command.INHERIT)
		:stderr(Command.INHERIT)
		:spawn()

	if not run_child then
		return fail("Failed to run %s: %s", target_binary, run_err)
	end

	-- Wait for the program to finish before returning to Yazi
	run_child:wait()
end

return { entry = entry }
