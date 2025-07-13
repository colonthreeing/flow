class_name Savefile extends Resource

var nodes : Array
var connections : Array
var vars : Dictionary
var camera : Dictionary

func _init(p_nodes : Array = [], graphedit: GraphEdit = GraphEdit.new(), p_vars : Dictionary = {}):
	nodes = p_nodes
	connections = graphedit.connections
	vars = p_vars
	camera = {
		"offset": graphedit.scroll_offset,
		"zoom": graphedit.zoom
	}

func serialize() -> Dictionary:
	return {
		"camera": camera,
		"nodes": nodes,
		"connections": connections,
		"vars": vars,
	}

static func deserialize(data):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("Item requires a dictionary")
	
	var graph := GraphEdit.new()
	var cam_data : Dictionary = data.get("camera", {})
	graph.connections = data.get("connections", [])
	graph.zoom = cam_data.get("zoom", 1.0)
	graph.scroll_offset = cam_data.get("offset", Vector2(0,0))
	
	return Savefile.new(
		data.get("nodes", []),
		graph,
		data.get("vars", {}),
	)

func save(path: String):
	var save_result = YAML.save_file(self, path)
	if !save_result.has_error():
		print("Game saved successfully!")
	else:
		push_error("Save failed: " + save_result.get_error())
