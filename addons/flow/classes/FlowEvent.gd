## Class for managing FlowNode connections.
class_name FlowEvent extends Resource

## The array of FlowNodes
var nodes  : Array[FlowNode] = []

func _init(p_nodes : Array[FlowNode] = []) -> void:
	nodes = p_nodes

func serialize() -> Dictionary:
	return {
		"nodes": nodes
	}

static func deserialize(data: Dictionary) -> FlowEvent:
	return FlowEvent.new(
		data.get("nodes", [])
	)
