-- WezTerm config. Originally ported from this machine's kitty setup (now removed —
-- kitty is no longer installed) to ease the switch: the keybindings below are
-- kitty's *default* ctrl+shift+* scheme rather than a personal customization, since
-- the old kitty.nix never rebound anything itself.

local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- Appearance -----------------------------------------------------------------------
config.font = wezterm.font("JetBrainsMonoNL Nerd Font")
config.font_size = 14.0
config.audible_bell = "Disabled" -- kitty: enable_audio_bell = false
config.window_close_confirmation = "NeverPrompt" -- kitty: confirm_os_window_close = 0

-- Keybindings: kitty's defaults ----------------------------------------------------
-- kitty "window" == a split pane within a tab; kitty "os window" == a wezterm
-- "window". Vanilla kitty ships with no split/pane keybindings at all (those require
-- opting into the `splits` layout yourself), which matches this setup, so panes
-- aren't mapped here either — only tabs, os-windows, clipboard, font size, and
-- scrolling, exactly like stock kitty.
config.keys = {
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

	-- jump to tab N (kitty binds ctrl+shift+1..0 to first_window..tenth_window,
	-- which selects panes by index; mapped to tabs here instead since this setup
	-- has no panes to select among)
	{ key = "1", mods = "CTRL|SHIFT", action = act.ActivateTab(0) },
	{ key = "2", mods = "CTRL|SHIFT", action = act.ActivateTab(1) },
	{ key = "3", mods = "CTRL|SHIFT", action = act.ActivateTab(2) },
	{ key = "4", mods = "CTRL|SHIFT", action = act.ActivateTab(3) },
	{ key = "5", mods = "CTRL|SHIFT", action = act.ActivateTab(4) },
	{ key = "6", mods = "CTRL|SHIFT", action = act.ActivateTab(5) },
	{ key = "7", mods = "CTRL|SHIFT", action = act.ActivateTab(6) },
	{ key = "8", mods = "CTRL|SHIFT", action = act.ActivateTab(7) },
	{ key = "9", mods = "CTRL|SHIFT", action = act.ActivateTab(8) },
	{ key = "0", mods = "CTRL|SHIFT", action = act.ActivateTab(9) },

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

	-- misc (kitty: toggle_fullscreen; kitty's ctrl+shift+f5 "reload config" has no
	-- equivalent keybinding needed here since wezterm auto-reloads on save)
	{ key = "F11", mods = "CTRL|SHIFT", action = act.ToggleFullScreen },
}

return config
