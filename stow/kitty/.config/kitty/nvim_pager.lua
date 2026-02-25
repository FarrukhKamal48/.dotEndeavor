dofile "/home/infidel/.config/nvim/lua/options.lua"
dofile "/home/infidel/.config/nvim/lua/keymaps.lua"

vim.keymap.set("n", "q", "<cmd>q!<CR>", {desc = "close pager", silent = false})
