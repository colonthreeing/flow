@tool 
extends EditorPlugin

const AUTOLOAD_NAME = 'Flow'

func _enable_plugin() -> void:
  add_autoload_singleton(AUTOLOAD_NAME, 'res://addons/flow/autoload.gd')

func _disable_plugin() -> void:
  remove_autoload_singleton(AUTOLOAD_NAME)
