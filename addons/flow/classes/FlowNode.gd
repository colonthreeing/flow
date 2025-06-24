## Class representing GodotFlow's nodes.
class_name FlowNode extends Resource

## Connections to other nodes
var connections : Array = []
## The node's unique identifier.
var id : StringName = &""
## The node's type.
var type : StringName = &""
## The node's data
var data : Dictionary = {}

## Make a new FlowNode
func _init(p_id : StringName = &"", p_type : StringName = &"", p_connections : Array = [], p_data = {}):
	id = p_id
	type = p_type
	connections = p_connections
	data = p_data

## Function used for YAML serialization
func serialize():
	return {
		"id": id,
		"type": type,
		"connections": connections,
		"data": data
	}

## Function used for YAML deserialization
static func deserialize(data: Dictionary):
	return FlowNode.new(
		data.get("id"),
		data.get("type"),
		data.get("connections", []),
		data.get("data", {})
	)
