## Class for managing FlowNode connections.
class_name FlowEvent extends Resource

## The array of FlowNodes
var nodes : Array = []

## The first node to be executed.
var start : FlowNode

## The event variables.
var vars : Dictionary

func _init(p_start : FlowNode = FlowNode.new(), p_nodes : Array = [], p_vars : Dictionary = {}) -> void:
	start = p_start
	nodes = p_nodes
	vars = p_vars

func serialize() -> Dictionary:
	return {
		"start": start,
		"nodes": nodes,
		"vars": vars
	}

static func deserialize(data: Dictionary) -> FlowEvent:
	return FlowEvent.new(
		data.get("start"),
		data.get("nodes", []),
		data.get("vars", {})
	)
