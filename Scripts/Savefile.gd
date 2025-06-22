class_name Savefile extends Resource

var nodes : Array
var connections : Array
var vars : Dictionary

func _init(p_nodes : Array = [], p_connections : Array = [], p_vars : Dictionary = {}):
	nodes = p_nodes
	connections = p_connections
	vars = p_vars

func serialize() -> Dictionary:
	return {
		"nodes": nodes,
		"connections": connections,
		"vars": vars
	}

static func deserialize(data):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("Item requires a dictionary")
	
	return Savefile.new(
		data.get("nodes", []),
		data.get("connections", []),
		data.get("vars", {})
	)

func save(path: String):
	var yml = YAML.new()
	
	var save_result = yml.save_file(self, path)
	if !save_result.has_error():
		print("Game saved successfully!")
	else:
		push_error("Save failed: " + save_result.get_error())
