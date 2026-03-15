dofile "/home/infidel/.config/nvim/lua/options.lua"
dofile "/home/infidel/.config/nvim/lua/keymaps.lua"

vim.keymap.set("i", "jk", "<Esc>", {desc = "exit in insert mode", silent = false})
vim.keymap.set("n", "q", "<cmd>q!<CR>", {desc = "close pager", silent = false})
vim.keymap.set("n", "<leader>E", "<cmd>:Lexplore<CR>", {desc = "open Lexplore", silent = false})
