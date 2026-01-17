// 1. Declare Global Types (MUST BE AT THE TOP)
declare global {
  interface GlideGlobals {
    is_sticky_hint_active?: boolean;
  }
}


// =============================================================================
// GLOBAL SETTINGS
// =============================================================================

glide.g.is_sticky_hint_active = false;
glide.g.mapleader = "<Space>";
glide.o.hint_size = "18px";
glide.o.scroll_implementation = "keys";

// Caret / Visual Mode Appearance
glide.prefs.set("ui.caretWidth", 1);
glide.prefs.set("ui.caretBlinkTime", 0);

// =============================================================================
// UNIVERSAL ESCAPE (Alt + ;)
// =============================================================================

// 1. For Normal, Hint, and Caret modes: stop sticky hints and return to Normal
glide.keymaps.set(["normal","insert","visual","ignore","command","op-pending"], "<A-;>", () => {
    glide.g.is_sticky_hint_active = false;
    glide.excmds.execute("hints_remove");
    glide.excmds.execute("clear");
    glide.excmds.execute("mode_change normal");
}, { description: "Universal Escape" });

// 2. For Insert mode: blur the active element to return to Normal
glide.keymaps.set("insert", "<A-;>", "blur", { 
    description: "Escape Insert Mode" 
});

// =============================================================================
// RECURSIVE STICKY HINTS LOGIC
// =============================================================================

const startStickyHints = () => {
    if (!glide.g.is_sticky_hint_active) return;

    glide.hints.show({
        action: async ({ content }) => {
            const url = await content.execute((el) => (el as HTMLAnchorElement).href);

            if (url) {
                const current = await glide.tabs.active();
                await browser.tabs.create({ 
                    url, 
                    active: false, 
                    index: current.index + 1 
                });

                // Wait 150ms to ensure Glide has finished the mode transition 
                // back to Normal before re-triggering Hint mode.
                setTimeout(startStickyHints, 150);
            } else {
                glide.g.is_sticky_hint_active = false;
            }
        }
    });
};

// =============================================================================
// KEYMAPS - NAVIGATION
// =============================================================================

// Reload config (Shift + R)
glide.keymaps.set("normal", "<leader>R", "config_reload");

// Smooth Scrolling
const scroll = (amount: number) => {
    return async ({ tab_id }: { tab_id: number }) => {
        await glide.content.execute((amt) => {
            window.scrollBy({ top: amt, behavior: "smooth" });
        }, { tab_id, args: [amount] });
    };
};

glide.keymaps.set("normal", "j", scroll(300));
glide.keymaps.set("normal", "k", scroll(-300));
glide.keymaps.set("normal", "J", scroll(800));
glide.keymaps.set("normal", "K", scroll(-800));
glide.keymaps.set("normal", "<A-j>", scroll(50));
glide.keymaps.set("normal", "<A-k>", scroll(-50));

// =============================================================================
// KEYMAPS - TABS & PAGES
// =============================================================================

// History Navigation (Using Back/Forward)
glide.keymaps.set("normal", "<A-h>", "back");
glide.keymaps.set("normal", "<A-l>", "forward");

// Tab Navigation (H and L)
glide.keymaps.set("normal", "H", "tab_prev");
glide.keymaps.set("normal", "L", "tab_next");
glide.keymaps.set("normal", "Q", "tab_close");

// New Tab logic
glide.keymaps.set("normal", "t", "tab_new");
glide.keymaps.set("normal", "T", async () => {
    const current = await glide.tabs.active();
    await browser.tabs.create({ active: true, index: current.index + 1 });
});

// =============================================================================
// KEYMAPS - HINTS & MODES
// =============================================================================

// Normal Background Hint (F)
glide.keymaps.set("normal", "F", () => {
    glide.hints.show({
        action: async ({ content }) => {
            const url = await content.execute((el) => (el as HTMLAnchorElement).href);
            if (url) {
                const current = await glide.tabs.active();
                await browser.tabs.create({ url, active: false, index: current.index + 1 });
            }
        }
    });
});

// STICKY HINT MODE (gF) - Removed space between g and F
glide.keymaps.set("normal", "gF", () => {
    glide.g.is_sticky_hint_active = true;
    startStickyHints();
});

// Focus Input (gi)
glide.keymaps.set("normal", "gi", () => {
    glide.hints.show({
        selector: "input:not([type='hidden']), textarea, [contenteditable]",
        auto_activate: true,
        action: async ({ content }) => {
            await content.execute((element) => {
                if (!element.hasAttribute("tabindex") && element.tagName !== "INPUT" && element.tagName !== "TEXTAREA") {
                    element.setAttribute("tabindex", "-1");
                }
                element.focus();
                element.click();
            });
            await glide.excmds.execute("mode_change insert");
        }
    });
});

// Focus Video Player (<leader>v) - Broad Selector + Focus Injection
glide.keymaps.set("normal", "<leader>v", () => {
    glide.hints.show({
        // 1. Loose Selector: Targets video/iframe tags OR anything with player-related terms in ID/Class
        selector: `
            video, 
            iframe, 
            [id*='player'], [class*='player'], 
            [id*='video'], [class*='video'], 
            [id*='media'], [class*='media'],
            .playable, .vjs-tech, .jwplayer
        `.replace(/\s+/g, ' ').trim(), // Clean up the string for Glide
        
        // 2. Automatically select if there's only one obvious winner
        auto_activate: true,

        action: async ({ content }) => {
            // 3. Prepare the element inside the page
            await content.execute((element) => {
                element.scrollIntoView({ block: "center", behavior: "smooth" });
                
                // Ensure it can receive focus
                if (!element.hasAttribute("tabindex")) {
                    element.setAttribute("tabindex", "-1");
                }
                element.focus();
                
                // Simulate a click gesture at the center to "wake up" the element
                const rect = element.getBoundingClientRect();
                const x = rect.left + rect.width / 2;
                const y = rect.top + rect.height / 2;
                const opts = { bubbles: true, clientX: x, clientY: y, view: window };
                element.dispatchEvent(new MouseEvent('mousedown', opts));
                element.dispatchEvent(new MouseEvent('mouseup', opts));
            });

            // 4. Delay to allow Glide's "Hint Mode" to finish closing
            // and the browser to settle focus on the frame.
            await new Promise(resolve => setTimeout(resolve, 250));

            // 5. Inject the Shift+Tab to transfer focus inside the frame/player
            await glide.keys.send("<S-Tab>");

            // 6. Final Mode Switch: Put Glide into Insert Mode
            await glide.excmds.execute("mode_change insert");
            
        }
    });
}, { description: "Broad-match focus video player" });

// =============================================================================
// UTILITIES & ESCAPE
// =============================================================================

// Clear / Escape
glide.keymaps.set(["normal", "hint"], "<Escape>", () => {
    glide.g.is_sticky_hint_active = false;
    glide.excmds.execute("hints_remove");
    glide.excmds.execute("clear");
});

// Insert Mode Escape
glide.keymaps.set("insert", "jk", "mode_change normal");
glide.keymaps.set("insert", "kj", "mode_change normal");

// Misc Tools
glide.keymaps.set("normal", "<leader>c", "clear");
glide.keymaps.set("normal", "<leader>h", "hints_remove");
glide.keymaps.set("normal", "<leader>L", "url_yank");
glide.keymaps.set("normal", "<leader>fp", "commandline_show");
glide.keymaps.set("normal", "-", "go_up");

// Zoom logic
glide.keymaps.set("normal", "<C-Up>", async () => {
    await browser.tabs.setZoom((await browser.tabs.getZoom()) + 0.1);
});
glide.keymaps.set("normal", "<C-Down>", async () => {
    await browser.tabs.setZoom((await browser.tabs.getZoom()) - 0.1);
});
