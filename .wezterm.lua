local wezterm = require("wezterm")
local act = wezterm.action
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
local config = wezterm.config_builder()
bar.apply_to_config(config,
	{
		position = "bottom",
		padding = {
			left = 1,
			right = 1,
			tabs = {
				left = 1,
				right = 1,
			}
		},
		modules = {
			spotify = {
				enabled = false,
			},
			separator = {
				space = 1,
			},
			workspace = {
				enabled = false
			},
			leader = {
				enabled = false
			},
			username = {
				enabled = false
			},
			hostname = {
				enabled = false
			},
			clock = {
				enabled = true
			},
			cwd = {
				enabled = false
			}
		}
	}
)
config.front_end = "WebGpu"
config.webgpu_power_preference = "LowPower"
config.max_fps = 60
config.default_cursor_style = "BlinkingBlock"
config.animation_fps = 1
config.cursor_blink_rate = 0
config.term = "xterm-256color"

config.font = wezterm.font("CaskaydiaCove NFM")
config.cell_width = 1
config.window_background_opacity = 0.75
config.prefer_egl = true
config.font_size = 12.5

config.window_padding = {
	left = 10,
	right = 1,
	top = 10,
	bottom = 6,
}

-- tabs
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 100
config.show_tab_index_in_tab_bar = false

-- keymaps
config.keys = {
	{
		key = "I",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitPane({
			direction = "Up",
			size = { Percent = 50 },
		}),
	},
	{
		key = "J",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitPane({
			direction = "Left",
			size = { Percent = 50 },
		}),
	},
	{
		key = "L",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitPane({
			direction = "Right",
			size = { Percent = 50 },
		}),
	},
	{
		key = "K",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitPane({
			direction = "Down",
			size = { Percent = 50 },
		}),
	},
	{
		key = "D",
		mods = "CTRL|SHIFT",
		action = act.ShowDebugOverlay
	},
	{
		key = "O",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, _)
			local overrides = window:get_config_overrides() or {}
			if overrides.window_background_opacity == 1.0 then
				overrides.window_background_opacity = 0.75
			else
				overrides.window_background_opacity = 1.0
			end
			window:set_config_overrides(overrides)
		end),
	},
	{
		key = 't',
		mods = 'CTRL',
		action = act.SpawnTab 'CurrentPaneDomain',
	},
	{
		key = 'w',
		mods = 'CTRL',
		action = wezterm.action.CloseCurrentPane { confirm = true },
	},
	{
		key = 'e',
		mods = 'ALT',
		action = act.PromptInputLine {
			description = 'Enter name for tab',
			initial_value = '',
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		},
	},
	{ key = "]", mods = "CTRL", action = wezterm.action { ActivatePaneDirection = "Next" } },
	{ key = "[", mods = "CTRL", action = wezterm.action { ActivatePaneDirection = "Prev" } },
}

config.color_scheme = "nord"
config.colors = {
	background = "#2e3440",
	cursor_border = "#5e81ac",
	cursor_bg = "#d8dee9",

	tab_bar = {
		-- background = "rgb(46, 52, 64 / 75%)", -- only used if tab is at top
		background = "rgb(0,0,0/0%)", -- only used if tab is at bottom
		active_tab = {
			bg_color = "#88c0d0",
			fg_color = "#2e3440",
			intensity = "Normal",
			underline = "None",
			italic = false,
			strikethrough = false,
		},
		inactive_tab = {
			bg_color = "#2e3440",
			fg_color = "#88c0d0",
			intensity = "Normal",
			underline = "None",
			italic = false,
			strikethrough = false,
		},
	},
}

config.window_decorations = "NONE | RESIZE"
config.default_prog = { "pwsh.exe", "-NoLogo"}
config.initial_cols = 80
return config
