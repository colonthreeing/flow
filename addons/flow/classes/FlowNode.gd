## Class representing GodotFlow's nodes.
class_name FlowNode extends RefCounted

## Connections to other nodes
var connections = []
## Node data based on property names.
var data = {}

func serialize():
	pass

static func deserialize():
	pass
