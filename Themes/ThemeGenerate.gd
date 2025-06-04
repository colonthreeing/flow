@tool
extends ProgrammaticTheme

const UPDATE_ON_SAVE = true

#region Color Defs
# Colors are from Catppuccin unless otherwise specified
var text_color = Color("#cdd6f4")
var text_color_hover = Color("#eff1f7") # My own color
var background_color = Color("#11111b")
var background_selected_color = Color("#181825")
var background_pressed_color = Color("#1e1e2e")
var background_disabled_color = Color("#11111b")

var surface_color_0 = Color("#313244")
var surface_color_1 = Color("#45475a")
var surface_color_2 = Color("#585b70")

var accent_color = Color("#cba6f7")
#endregion

#region Theme Values
var corner_rad = 3
var general_border_width = 2
var margins = 5
#endregion

func setup_dark_theme():
	set_save_path("res://Themes/generated/dark_theme.tres")

func setup_light_theme():
	text_color = Color("#4c4f69")
	text_color_hover = Color("37394f")
	
	background_color = Color("#dce0e8") # Crust
	background_selected_color = Color("#e6e9ef") # Mantle
	background_pressed_color = Color("#eff1f5") # Base
	background_disabled_color = Color("#dce0e8") # Crust again (??)

	surface_color_0 = Color("#ccd0da")
	surface_color_1 = Color("#bcc0cc")
	surface_color_2 = Color("#acb0be")

	accent_color = Color("#7287fd")
	
	set_save_path("res://Themes/generated/light_theme.tres")

func define_theme():
	var general_background_style = stylebox_flat({
		bg_color = surface_color_0,
		content_margin_ = content_margins(margins),
		corner_ = corner_radius(corner_rad),
	})
	
	var panel_style = inherit(general_background_style, {
		bg_color = background_color,
		# border_ = border_width(2)
	})
	
	var general_hover_style = inherit(panel_style, {
		bg_color = surface_color_2,
#		border_color = surface_color_2,
#		border_ = border_width(general_border_width)
	})
	
	var general_focus_style = inherit(panel_style, {
		bg_color = background_selected_color,
		border_color = accent_color,
		# border_ = border_width(general_border_width)
	})
	
	var general_disabled_style = inherit(panel_style, {
		bg_color = background_disabled_color
	})
	
	define_style("Label", {
		font_color = text_color
	})
	
	define_style("Panel", {
		panel = general_background_style
	})
	
	define_style("PanelContainer", {
		panel = general_background_style,
#		corner_ = corner_radius(corner_rad, corner_rad, 0, 0),
#		border_color = accent_color,
#		border_ = border_width(general_border_width),
	})
	
	var menu = inherit(general_disabled_style, {
		corner_ = corner_radius(corner_rad),
		border_color = accent_color,
		border_ = border_width(general_border_width)
	})
	
	define_variant_style("Menu", "PanelContainer", {
		panel = menu
	})
	
	var button_normal_style = inherit(panel_style, {
		content_margin_ = content_margins(margins),
	})
	var button_hover_style = merge(button_normal_style, general_hover_style)
	var button_focus_style = merge(button_normal_style, general_focus_style)
	var button_pressed_style = inherit(button_focus_style, {
		bg_color = surface_color_1
	})
	
	define_style("Button", {
		normal = button_normal_style,
		hover = button_hover_style,
		focus = button_focus_style,
		pressed = button_pressed_style,
		disabled = inherit(button_normal_style, general_disabled_style),
		font_color = text_color,
		
		# color gore
		font_pressed_color = text_color,
		font_hover_color = text_color_hover,
		font_focus_color = text_color_hover,
		font_hover_pressed_color = text_color_hover,
		font_disabled_color = text_color
	})
	
	define_style("GraphEdit", {
		panel = inherit(panel_style, {bg_color = background_pressed_color}),
		menu_panel = general_hover_style,
		
		grid_major = surface_color_1,
		grid_minor = surface_color_0,
		
		connection_rim_color = background_pressed_color,
		connection_valid_target_tint_color = Color(1.0, 1.0, 1.0, 0.0), #  - background_color,
		activity = Color(1.0, 1.0, 1.0, 2.0) - background_color,
		
		selection_fill = Color(1.0, 1.0, 1.0, 1.4) - background_color,
		selection_stroke = Color(1.0, 1.0, 1.0, 1.8) - background_color
	})
	
	# Shitty defs but I think they work well enough
	# Not like it needs to run anywhere *near* real time so optimization isn't a problem
	define_style("GraphNode", {
		port = load("res://Themes/images/GuiGraphNodePort.svg"),
		titlebar = inherit(panel_style, {corner_ = corner_radius(corner_rad, corner_rad, 0, 0)}),
		titlebar_selected = inherit(button_focus_style, {
			corner_ = corner_radius(corner_rad, corner_rad, 0, 0),
			border_color = accent_color,
			border_ = border_width(general_border_width, general_border_width, general_border_width, 0),
		}),
		
		panel = inherit(general_background_style, {
			bg_color = surface_color_0,
			border_color = background_color,
			border_ = border_width(general_border_width, 0, general_border_width, general_border_width),
			corner_ = corner_radius(0, 0, corner_rad, corner_rad),
			margin_ = content_margins(margins + 10, margins, margins + 10, margins)
		}),
		panel_selected = inherit(general_background_style, {
			bg_color = surface_color_0,
			border_color = accent_color,
			border_ = border_width(general_border_width, 0, general_border_width, general_border_width),
			corner_ = corner_radius(0, 0, corner_rad, corner_rad),
			margin_ = content_margins(margins + 10, margins, margins + 10, margins)
		}),
	})
	
	var text_edit_style = {
		focus = inherit(general_focus_style, {
			border_ = border_width(general_border_width, general_border_width, general_border_width, general_border_width),
		}),
		normal = button_normal_style,
		read_only = general_disabled_style,
		
		font_color = text_color,
		font_placeholder_color = text_color * Color(1.0,1.0,1.0,0.6),
		font_selected_color = text_color_hover,
		
		caret_color = text_color
	}
	
	define_style("LineEdit", text_edit_style)
	
	define_style("TextEdit", text_edit_style)
	
	define_style("Tree", {
		panel = panel_style,
		
		font_color = text_color,
		font_placeholder_color = text_color * Color(1.0,1.0,1.0,0.6),
		font_selected_color = text_color_hover,
		
		button_hover = button_hover_style,
		button_pressed = button_pressed_style,
		
		inner_item_margin_left = margins,
		
		selected = inherit(button_focus_style, {
			border_ = border_width(general_border_width, general_border_width, general_border_width, general_border_width),
			border_color = accent_color
		}),
	})
	
	define_style("PopupMenu", {
		panel = menu,
		hover = button_hover_style,
		
		font_color = text_color,
		font_placeholder_color = text_color * Color(1.0,1.0,1.0,0.6),
		font_selected_color = text_color_hover,
		font_hover_color = text_color,
	})
	
	define_style("PopupPanel", {
		panel = menu
	})
