extends Node


func _init() -> void:
	YAML.register_class(FlowEvent)
	YAML.register_class(FlowNode)
