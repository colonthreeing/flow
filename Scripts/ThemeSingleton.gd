extends Node

var dark = true

func load_theme_icon(icon_filepath: String):
	return load("res://Themes/images/%s/%s" % ["dark" if dark else "light", icon_filepath])
