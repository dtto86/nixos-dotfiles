-- WezTerm config. Originally ported from this machine's kitty setup (kitty is no longer
-- installed). Kept as a plain terminal: splits, workspaces and session persistence are
-- left to herdr, so only kitty-style CTRL+SHIFT bindings live here and every `wezterm`
-- launch is a plain new window.

local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- Tokyo Night Moon palette, used for the tab bar / status where the scheme doesn't reach.
local c = {
	bg = "#222436",
	bg_dark = "#1e2030",
	bg_hl = "#2f334d",
	fg = "#c8d3f5",
	comment = "#636da6",
	blue = "#82aaff",
	cyan = "#86e1fc",
	green = "#c3e88d",
	magenta = "#c099ff",
	orange = "#ff966c",
	yellow = "#ffc777",
}

-- Appearance -----------------------------------------------------------------------
config.color_scheme = "Tokyo Night Moon"
config.font = wezterm.font_with_fallback({
	"JetBrainsMono Nerd Font",
	"Symbols Nerd Font Mono", -- bundled with wezterm
	"Noto Color Emoji", -- bundled with wezterm
})
config.font_size = 13.0
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
config.line_height = 1.05

config.window_background_opacity = 0.95
config.window_decorations = "NONE" -- Hyprland tiles it, no need for a title bar
config.window_padding = { left = 8, right = 8, top = 8, bottom = 4 }
config.inactive_pane_hsb = { saturation = 0.8, brightness = 0.6 }

config.enable_wayland = true
config.front_end = "WebGpu"
config.max_fps = 120

config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 600
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- Tab bar: retro (non-fancy) style at the bottom, hidden when there's only one tab.
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32
config.colors = {
	tab_bar = {
		background = c.bg_dark,
		active_tab = { bg_color = c.blue, fg_color = c.bg_dark, intensity = "Bold" },
		inactive_tab = { bg_color = c.bg_dark, fg_color = c.comment },
		inactive_tab_hover = { bg_color = c.bg_hl, fg_color = c.fg },
	},
}

-- Behaviour ------------------------------------------------------------------------
config.default_prog = { "zsh", "-l" }
config.scrollback_lines = 50000
config.audible_bell = "Disabled" -- kitty: enable_audio_bell = false
config.window_close_confirmation = "NeverPrompt" -- kitty: confirm_os_window_close = 0
config.check_for_updates = false
config.adjust_window_size_when_changing_font_size = false
config.switch_to_last_active_tab_when_closing_tab = true

-- Hyperlinks: defaults plus bare GitHub "owner/repo" references. CTRL+click opens them.
config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
	regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
	format = "https://github.com/$1/$3",
})
config.mouse_bindings = {
	-- plain click only selects; CTRL+click opens the link under the cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelection("ClipboardAndPrimarySelection"),
	},
	{ event = { Up = { streak = 1, button = "Left" } }, mods = "CTRL", action = act.OpenLinkAtMouseCursor },
	{ event = { Down = { streak = 1, button = "Left" } }, mods = "CTRL", action = act.Nop },
}

-- Keybindings ----------------------------------------------------------------------
config.keys = {
	-- Kitty-style CTRL+SHIFT bindings ----------------------------------------------
	-- clipboard (kitty: copy_to_clipboard / paste_from_clipboard)
	{ key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

	-- os windows (kitty: new_window / new_os_window_with_cwd)
	{ key = "Enter", mods = "CTRL|SHIFT", action = act.SpawnWindow },
	{
		key = "n",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(_, pane)
			local cwd_uri = pane:get_current_working_dir()
			wezterm.mux.spawn_window({ cwd = cwd_uri and cwd_uri.file_path or nil })
		end),
	},

	-- tabs (kitty: new_tab / close_tab / next_tab / previous_tab /
	-- move_tab_forward / move_tab_backward)
	{ key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
	{ key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
	{ key = "LeftArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = ".", mods = "CTRL|SHIFT", action = act.MoveTabRelative(1) },
	{ key = ",", mods = "CTRL|SHIFT", action = act.MoveTabRelative(-1) },

	-- font size (kitty: increase_font_size / decrease_font_size / restore_font_size)
	{ key = "=", mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
	{ key = "+", mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
	{ key = "-", mods = "CTRL|SHIFT", action = act.DecreaseFontSize },
	{ key = "Backspace", mods = "CTRL|SHIFT", action = act.ResetFontSize },

	-- scrolling (kitty: scroll_line_up/down, scroll_page_up/down, scroll_home/end)
	{ key = "UpArrow", mods = "CTRL|SHIFT", action = act.ScrollByLine(-1) },
	{ key = "DownArrow", mods = "CTRL|SHIFT", action = act.ScrollByLine(1) },
	{ key = "PageUp", mods = "CTRL|SHIFT", action = act.ScrollByPage(-1) },
	{ key = "PageDown", mods = "CTRL|SHIFT", action = act.ScrollByPage(1) },
	{ key = "Home", mods = "CTRL|SHIFT", action = act.ScrollToTop },
	{ key = "End", mods = "CTRL|SHIFT", action = act.ScrollToBottom },
	{ key = "h", mods = "CTRL|SHIFT", action = act.ActivateCopyMode }, -- kitty: show_scrollback

	-- misc (kitty: toggle_fullscreen)
	{ key = "F11", mods = "CTRL|SHIFT", action = act.ToggleFullScreen },
}

-- CTRL+SHIFT 1..0 jumps to tab N (kitty-style)
for i = 1, 10 do
	table.insert(config.keys, { key = tostring(i % 10), mods = "CTRL|SHIFT", action = act.ActivateTab(i - 1) })
end

-- Tab titles: "index: process" ----------------------------------------------------
local function basename(s)
	return (s or ""):gsub("(.*[/\\])(.*)", "%2")
end

wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
	local pane = tab.active_pane
	local title = tab.tab_title
	if not title or title == "" then
		title = basename(pane.foreground_process_name)
		if title == "" then
			title = pane.title
		end
	end
	local text = string.format(" %d: %s ", tab.tab_index + 1, title)
	return wezterm.truncate_right(text, max_width)
end)

-- Status: cwd and clock on the right of the tab bar (only visible with 2+ tabs) -----
wezterm.on("update-status", function(window, pane)
	local cwd = pane:get_current_working_dir()
	local dir = cwd and basename(cwd.file_path:gsub("/$", "")) or ""

	window:set_right_status(wezterm.format({
		{ Foreground = { Color = c.comment } },
		{ Text = "  " .. dir .. "  " },
		{ Foreground = { Color = c.magenta } },
		{ Text = wezterm.strftime("%H:%M") .. " " },
	}))
end)

return config
