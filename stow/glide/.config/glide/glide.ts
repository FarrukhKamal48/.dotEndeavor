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
glide.o.mapping_timeout = 70;
glide.o.hint_size = "18px";
glide.o.hint_chars = "hjklasdgyuiopqwertnmzxcvb";
glide.o.scroll_implementation = "keys";

// Caret / Visual Mode Appearance
glide.prefs.set("ui.caretWidth", 1);
glide.prefs.set("ui.caretBlinkTime", 0);

// make the mode button more visible and prominent
glide.styles.add(css`
    :root {
        --glide-mode-normal: #89b4fa;
        --glide-mode-insert: #a6e3a1;
        --glide-mode-hint: #cba6f7;
        --glide-mode-command: #fab387;
        --glide-mode-op-pending: #fb4934;
        --glide-mode-visual: #f38ba8;
    }
`);
glide.styles.add(css`
  #glide-toolbar-mode-button {
      color: #181825;
      font-weight: bold;
      background-color: var(--toolbarbutton-icon-fill-attention, #45a9ff);
      border-radius: 5px;
  }
  #glide-toolbar-mode-button.glide-mode-button {
      min-width: auto;
      justify-content: center !important;
      margin-top : 5px;
      margin-bottom : 5px;
      padding-right: 10px;
      padding-left: 10px;
  }
  #glide-toolbar-mode-button.glide-mode-button::after {
      width: 0;
  }
`);

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
glide.keymaps.set("insert", "<A-'>", "blur", { 
    description: "Escape Insert Mode" 
});

const clickBackground = async ({ tab_id }: { tab_id: number }) => {
    await glide.content.execute(() => {
        // 1. Deactivate (Blur) any focused element
        if (document.activeElement instanceof HTMLElement) {
            document.activeElement.blur();
        }

        // 2. Define standard Click Options
        const eventOptions: MouseEventInit = {
            view: window,
            bubbles: true,
            cancelable: true,
            buttons: 1
        };

        // 3. Dispatch events
        document.body.dispatchEvent(new MouseEvent("mousedown", eventOptions));
        document.body.dispatchEvent(new MouseEvent("mouseup", eventOptions));
        document.body.dispatchEvent(new MouseEvent("click", eventOptions));
    }, { tab_id });
};

glide.keymaps.set("normal", "<leader>d", clickBackground, { description: "Click background to dismiss/blur" });

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
glide.keymaps.set("normal", "<S-j>", scroll(800));
glide.keymaps.set("normal", "<S-k>", scroll(-800));
glide.keymaps.set("normal", "<A-j>", scroll(50));
glide.keymaps.set("normal", "<A-k>", scroll(-50));

// =============================================================================
// KEYMAPS - TABS & PAGES
// =============================================================================

// History Navigation (Using Back/Forward)
glide.keymaps.set("normal", "n", "back");
glide.keymaps.set("normal", "m", "forward");

// Tab manipulation
glide.keymaps.set("normal", "<S-h>", "tab_prev");
glide.keymaps.set("normal", "<S-l>", "tab_next");
glide.keymaps.set("normal", "q", "tab_close");
glide.keymaps.set("normal", "r", "reload")


// New Tab logic
glide.keymaps.set("normal", "t", "tab_new");
glide.keymaps.set("normal", "<S-t>", async () => {
    const current = await glide.tabs.active();
    await browser.tabs.create({ active: true, index: current.index + 1 });
});

// =============================================================================
// KEYMAPS - HINTS & MODES
// =============================================================================


// hints to open in current tab
glide.keymaps.set("normal", "f", () => {
    glide.hints.show({
        action: async ({ content }) => {
            const url = await content.execute((el) => (el as HTMLAnchorElement).href);
            if (url) {
                const current = await glide.tabs.active();
                await browser.tabs.update(current.id, { url, active: false });
            }
        }
    });
});

// hints to open in new tab
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

// hints for browser-ui
glide.keymaps.set("normal", "gf", () => {
    glide.hints.show({
        action: "click",
        location: "browser-ui",
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
            })
            // setTimeout(() => glide.keys.send("<S-a>"), 50);
            glide.keys.send("<S-a>");
        }
    });
});

// Scrollable element hints
glide.keymaps.set("normal", "gs", () => {
    glide.hints.show({
        selector: "div, section, article, aside, nav, ul, ol, pre, code, main, textarea, [class*='scroll']",
        
        pick: async ({ content, hints }) => {
            const results = await content.map((element: HTMLElement) => {
                const style = window.getComputedStyle(element);
                
                const overflowY = style.overflowY;
                const overflowX = style.overflowX;
                const isScrollableStyle = 
                    (overflowY === 'auto' || overflowY === 'scroll') ||
                    (overflowX === 'auto' || overflowX === 'scroll');

                const canScroll = 
                    element.scrollHeight > element.clientHeight || 
                    element.scrollWidth > element.clientWidth;

                const hasScrollClass = element.className.includes("scroll");
                const isNotRoot = element !== document.body && element !== document.documentElement;

                return (isScrollableStyle || hasScrollClass) && canScroll && isNotRoot;
            });

            const filteredHints = hints.filter((_, i) => results[i]);

            // FIX: Added '{}' as the second argument to execute()
            if (filteredHints.length === 0) {
                glide.excmds.execute("hints_remove");
                glide.excmds.execute("mode_change normal");
            }

            return filteredHints;
        },

        action: async ({ content }) => {
            await content.execute((element: HTMLElement) => {
                element.scrollIntoView({ block: "center", behavior: "smooth" });

                if (!element.hasAttribute("tabindex")) {
                    element.setAttribute("tabindex", "-1");
                }
                element.focus();

                const originalOutline = element.style.outline;
                element.style.outline = "2px solid red";
                setTimeout(() => {
                    element.style.outline = originalOutline;
                }, 600);
            });
        }
    });
}, { description: "Focus scrollable elements" });

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
// glide.keymaps.set("insert", "kj", "mode_change normal");

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
