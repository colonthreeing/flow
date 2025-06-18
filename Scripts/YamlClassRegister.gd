extends Node


func _init() -> void:
	YAML.register_class(Savefile)
	YAML.register_class(DynamicGraphNode)
