@tool
extends ProgrammaticTheme

const UPDATE_ON_SAVE = true

#region Color Defs
var text_color = Color("#cdd6f4")

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

#region Texture Values
var circle = load("res://Themes/images/circle.svg")
#endregion

func setup_dark_theme():
	set_save_path("res://Themes/generated/dark_theme.tres")

func setup_light_theme():
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
		# border_color = accent_color,
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
		content_margin_ = content_margins(margins)
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
		disabled = inherit(button_normal_style, general_disabled_style)
	})
	
	define_style("GraphEdit", {
		panel = inherit(panel_style, {bg_color = background_pressed_color}),
		menu_panel = general_hover_style,
		
		grid_major = surface_color_1,
		grid_minor = surface_color_0,
	})
	
	# Shitty defs but I think they work well enough
	define_style("GraphNode", {
		# port = circle
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
		read_only = general_disabled_style
	}
	
	define_style("LineEdit", text_edit_style)
	
	define_style("TextEdit", text_edit_style)
	
	define_style("Tree", {
		panel = panel_style,
		
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
		hover = button_hover_style
	})
