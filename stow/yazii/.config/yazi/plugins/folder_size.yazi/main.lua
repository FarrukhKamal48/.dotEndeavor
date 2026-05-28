-- ~/.config/yazi/plugins/folder-size.yazi/main.lua

-- This function will be called by Yazi to render the custom linemode.
function Linemode:folder_size(area, files)
	local lines = {}

	for _, file in ipairs(files) do
		local size_str = ""
		if file.is_dir then
			-- If the entry is a directory, run `du -sh` to get its size.
			local output, err = Command('du -sh --apparent-size "' .. tostring(file.url) .. '"'):output()
			if err == nil and output ~= nil then
				-- Extract the size from the command output.
				size_str = output:match("^[^\t]+")
			else
				size_str = "N/A"
			end
		else
			-- If it's a file, use the default readable_size function.
			size_str = ya.readable_size(file.size)
		end
		table.insert(lines, ui.Line({ ui.Span(size_str) }))
	end

	return ui.Paragraph(area, lines):align(ui.Paragraph.RIGHT)
end
