// ~/.config/glide/glide.ts

// =============================================================================
// CARET / VISUAL MODE APPEARANCE
// =============================================================================

// Make the caret 10px thick (effectively a block cursor)
// Note: This applies globally (including in the address bar)
glide.prefs.set("ui.caretWidth", 1);

// Optional: Stop the caret from blinking to make it easier to track
glide.prefs.set("ui.caretBlinkTime", 0);

// =============================================================================
// GENERAL SETTINGS & LEADER
// =============================================================================

glide.o.hint_size = "18px";

// Set space as leader (Matches your: vim.g.mapleader = " ")
glide.g.mapleader = "<Space>";

// Set scroll behavior to keys to ensure J/K mappings work reliably
glide.o.scroll_implementation = "keys";

// Set hint charectors (remvove 'f')
glide.o.hint_chars = "hjklasdgyuiopqwertnmzxcvb"

// Reload config
glide.keymaps.set("normal", "<leader>R", "config_reload", { 
    description: "Reload Glide configuration" 
});

// =============================================================================
// NAVIGATION (The "Sonic" Movements)
// =============================================================================

let scroll_speed = 150;
let scroll_multiplier = 3;
let scroll_behavior : ScrollBehavior = "smooth"

// Smooth Scroll Down
glide.keymaps.set("normal", "j", async ({ tab_id }) => {
    await glide.content.execute((speed, behavior) => {
        window.scrollBy({ top: speed, behavior: behavior });
    }, { tab_id, args:[scroll_speed, scroll_behavior] });
});

// Smooth Scroll Up
glide.keymaps.set("normal", "k", async ({ tab_id }) => {
    await glide.content.execute((speed, behavior) => {
        window.scrollBy({ top: -speed, behavior: behavior });
    }, { tab_id, args:[scroll_speed, scroll_behavior] });
});

// Lua: keymap("n", "<S-j>", "5j", opts) -> Move Down Fast
glide.keymaps.set("normal", "J", async ({ tab_id }) => {
    await glide.content.execute((speed, multiplier, behavior) => {
        window.scrollBy({ top: speed * multiplier, behavior: behavior });
    }, { tab_id, args:[scroll_speed, scroll_multiplier, scroll_behavior] });
}, { description: "Sonic Down (10j)" });

// Lua: keymap("n", "<S-k>", "5k", opts) -> Move Up Fast
glide.keymaps.set("normal", "K", async ({ tab_id }) => {
    await glide.content.execute((speed, multiplier, behavior) => {
        window.scrollBy({ top: -speed * multiplier, behavior: behavior });
    }, { tab_id, args:[scroll_speed, scroll_multiplier, scroll_behavior] });
}, { description: "Sonic Up (10k)" });

// Lua: keymap("n", "<S-A-j>", "15j", opts) -> Super Sonic Down
// In browser, <C-d> (Scroll half page) is a good equivalent to 15j
glide.keymaps.set("normal", "<A-S-j>", async ({ tab_id }) => {
    await glide.content.execute((behavior) => {
        window.scrollBy({ top: 1800, behavior: behavior });
    }, { tab_id, args:[scroll_behavior] });
}, { description: "Super-Sonic Down" });

// Lua: keymap("n", "<S-A-k>", "15k", opts) -> Super Sonic Up
glide.keymaps.set("normal", "<A-S-k>", async ({ tab_id }) => {
    await glide.content.execute((behavior) => {
        window.scrollBy({ top: -1800, behavior: behavior });
    }, { tab_id, args:[scroll_behavior] });
}, { description: "Super-Sonic Up" });


// Page Next and previous
glide.keymaps.set("normal", "H", "back", { description: "Previous Page" });
glide.keymaps.set("normal", "H", "forward", { description: "Next Page" });


// =============================================================================
// TABS / BUFFERS NAVIGATION
// =============================================================================

// Map 't' to open a new tab (automatically focuses the URL bar)
glide.keymaps.set("normal", "t", "tab_new", { description: "Open new tab" });

// Map 't' to open a new tab immediately after the current one
glide.keymaps.set("normal", "T", async () => {
    // 1. Get the current tab location
    const current = await glide.tabs.active();
    
    // 2. Create a new tab at the next index (Right below/next to current)
    await browser.tabs.create({
        active: true,
        index: current.index + 1
    });
}, { description: "Open new tab next to current" });

// Lua: keymap("n", "<S-h>", ":bprevious<CR>", opts)
// Glide: Switch to previous tab
glide.keymaps.set("normal", "H", "tab_prev", { description: "Previous Tab" });

// Lua: keymap("n", "<S-l>", ":bnext<CR>", opts)
// Glide: Switch to next tab
glide.keymaps.set("normal", "L", "tab_next", { description: "Next Tab" });

// Lua: keymap("n", "<S-q>", "<cmd>Bdelete!<CR>", opts)
// Glide: Close current tab
glide.keymaps.set("normal", "q", "tab_close", { description: "Close Tab" });

// Lua: keymap("n", "<leader>fp", ":ProjectFzf<CR>")
// Glide: Open Tab Search / Command Line
glide.keymaps.set("normal", "<leader>fp", "commandline_show", { description: "Search Tabs/Commands" });


// =============================================================================
// WINDOW / ZOOM MANAGEMENT
// =============================================================================

// Lua: keymap("n", "<C-Up>", ":resize -2<CR>")
// Glide: Zoom In (Closest equivalent to resizing a window split)
glide.keymaps.set("normal", "<C-Up>", async () => {
    const currentZoom = await browser.tabs.getZoom();
    await browser.tabs.setZoom(currentZoom + 0.1);
}, { description: "Zoom In" });

// Lua: keymap("n", "<C-Down>", ":resize +2<CR>")
// Glide: Zoom Out
glide.keymaps.set("normal", "<C-Down>", async () => {
    const currentZoom = await browser.tabs.getZoom();
    await browser.tabs.setZoom(currentZoom - 0.1);
}, { description: "Zoom Out" });

// Lua: keymap("n", "<C-h>", "<C-w>h", opts) -> Window Left
// In a browser, we can map this to switching to the tab to the immediate left
// glide.keymaps.set("normal", "<C-h>", "tab_prev");
// glide.keymaps.set("normal", "<C-l>", "tab_next");


// Map 'gi' to focus an input and automatically switch to Insert Mode
glide.keymaps.set("normal", "g i", () => {
    glide.hints.show({
        // 1. Selector for all common editable fields
        selector: "input:not([type='hidden']), textarea, [contenteditable]",
        
        // 2. If there is only one (like Google Search), it focuses instantly
        auto_activate: true,

        action: async ({ content }) => {
            // 3. Prepare and focus the element inside the web page
            await content.execute((element) => {
                // Ensure the element is focusable (crucial for [contenteditable] divs)
                if (!element.hasAttribute("tabindex") && 
                    element.tagName !== "INPUT" && 
                    element.tagName !== "TEXTAREA") {
                    element.setAttribute("tabindex", "-1");
                }
                element.focus();
                
                // For some inputs, a click is required to trigger site-specific logic
                element.click();
            });

            // 4. Change mode to insert using the official excmd
            await glide.excmds.execute("mode_change insert");
            
            glide.notify("Input focused (Insert Mode)");
        }
    });
}, { description: "Focus input and enter Insert Mode" });


// Map <leader>v to focus the video player and switch to Insert Mode via excmd
glide.keymaps.set("normal", "<leader>v", () => {
    glide.hints.show({
        // Selector for video tags and common player IDs/classes
        selector: "video, [id*='player'], [class*='player']",
        
        auto_activate: true,

        action: async ({ content }) => {
            // 1. Prepare and focus the element inside the web page
            await content.execute((element) => {
                // Ensure the element can receive focus
                if (!element.hasAttribute("tabindex")) {
                    element.setAttribute("tabindex", "-1");
                }
                element.focus();
                element.scrollIntoView({ block: "center", behavior: "smooth" });
            });

            // 2. Execute the mode_change excmd to enter insert mode
            // This matches the schema: name="mode_change", arg[0]="insert"
            await glide.excmds.execute("mode_change insert");
            
            glide.notify("Player focused (Insert Mode)");
        }
    });
}, { description: "Focus video player" });


// =============================================================================
// URL & HIERARCHY (OIL.NVIM)
// =============================================================================

// Lua: vim.keymap.set("n", "-", "<cmd>Oil --float<CR>")
// Glide: Go up one directory level in the URL (e.g. site.com/foo/bar -> site.com/foo)
glide.keymaps.set("normal", "-", "go_up", { description: "Go up URL hierarchy" });



// =============================================================================
// INSERT MODE ESCAPE
// =============================================================================

// // Lua: keymap("i", "jk", "<ESC>", opts)
// // Glide: Blurs the active input element to return to Normal mode
// glide.keymaps.set("insert", "jk", "blur", { description: "Escape Insert Mode" });
//
// // Lua: keymap("i", "kj", "<ESC>", opts)
// glide.keymaps.set("insert", "kj", "blur");
//

// =============================================================================
// COPYING & CLIPBOARD
// =============================================================================

// Lua: keymap("v", "<leader>L", ...) -> Copy reference
// Glide: Yank current URL
glide.keymaps.set("normal", "<leader>L", "url_yank", { description: "Yank URL" });

// Lua: keymap("n", "<C-a>", "ggVG", opts) -> Select All
glide.keymaps.set("normal", "<C-a>", async () => {
    // We use content execution to select text on the page
    await glide.content.execute(() => {
        document.execCommand("selectAll");
    });
}, { description: "Select All" });

// // =============================================================================
// // VISUAL / CARET MODE
// // =============================================================================
//
// // 1. Press 'v' in Normal mode to enter Caret mode
// glide.keymaps.set("normal", "v", "mode_change visual", { 
//     description: "Enter Visual (Caret) Mode" 
// });
//
// // 2. Press 'y' in Caret mode to copy the selection and return to Normal mode
// glide.keymaps.set("visual", "y", "visual_selection_copy", { 
//     description: "Yank selection" 
// });
//
// // 3. Press 'Esc' (or your 'jk' bind) to exit Caret mode without copying
// glide.keymaps.set("visual", "<Escape>", "mode_change normal");
// glide.keymaps.set("visual", "jk", "mode_change normal");
//
// // OPTIONAL: Ensure basic movement exists in Caret mode if not default
// // (Glide usually defaults these, but explicit is safer)
// glide.keymaps.set("visual", "h", "caret_move left");
// glide.keymaps.set("visual", "l", "caret_move right");
// glide.keymaps.set("visual", "j", "caret_move down");
// glide.keymaps.set("visual", "k", "caret_move up");

// =============================================================================
// MISC / TOOLS
// =============================================================================

// Map <leader>c to clear all notifications (warnings, errors, etc.)
glide.keymaps.set("normal", "<leader>c", "clear", { 
    description: "Clear notifications" 
});

// Map 'F' to open hints in a background tab immediately after the current one
glide.keymaps.set("normal", "F", () => {
    glide.hints.show({
        action: async ({ content }) => {
            // 1. Get the URL from the hinted element
            const url = await content.execute((element) => {
                return (element as HTMLAnchorElement).href;
            });

            if (url) {
                // 2. Get the current active tab info
                const currentTab = await glide.tabs.active();

                // 3. Create the new tab at the next index position
                await browser.tabs.create({ 
                    url: url, 
                    active: false,               // Do not switch focus
                    index: currentTab.index + 1  // Insert right after current tab
                });
                
            } else {
            }
        }
    });
}, { description: "Open hint in background tab (next)" });

// Lua: keymap("n", "<leader>h", "<cmd>nohlsearch<CR>", opts)
// Glide: Remove hints (and generic clear)
glide.keymaps.set("normal", "<leader>h", "hints_remove", { description: "Clear Hints" });

// Lua: keymap("n", "<leader>gg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>")
// Glide: Open GitHub or current repo logic
glide.keymaps.set("normal", "<leader>gg", async () => {
    const url = new URL(glide.ctx.url);
    // If we are on github, go to issues, otherwise go to github home
    if (url.hostname === "github.com") {
         // Append /issues if not there
         if (!url.pathname.includes("/issues")) {
             url.pathname = url.pathname + "/issues";
             await browser.tabs.update({ url: url.toString() });
         }
    } else {
        await browser.tabs.create({ url: "https://github.com" });
    }
}, { description: "LazyGit / GitHub" });

// Lua: keymap("n", "<leader>e", ":NvimTreeToggle<CR>")
// Glide: Toggle Sidebar (Bookmarks/History)
glide.keymaps.set("normal", "<leader>e", async () => {
    await browser.sidebarAction.toggle();
}, { description: "Toggle Sidebar" });


// =============================================================================
// CUSTOM BOOKMARK PICKER (Like Telescope)
// =============================================================================

// Maps <leader>fb to a fuzzy finder for bookmarks
glide.keymaps.set("normal", "<leader>fb", async () => {
    const bookmarks = await browser.bookmarks.getRecent(20);
  
    glide.commandline.show({
      title: "Telescope Bookmarks",
      options: bookmarks.map((bookmark) => ({
        label: bookmark.title || bookmark.url || "Untitled",
        description: bookmark.url,
        async execute() {
          if (bookmark.url) {
              await browser.tabs.create({ active: true, url: bookmark.url });
          }
        },
      })),
    });
  }, { description: "Telescope Bookmarks" });


