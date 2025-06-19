class_name Savefile extends Resource

var nodes : Array

func _init(p_nodes : Array = []):
	nodes = p_nodes

func serialize() -> Dictionary:
	return {
		"nodes": nodes
	}

static func deserialize(data):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("Item requires a dictionary")
	
	return Savefile.new(
		data.get("nodes", [])
	)

func save(path: String):
	var yml = YAML.new()
	
	var save_result = yml.save_file(self, path)
	if !save_result.has_error():
		print("Game saved successfully!")
	else:
		push_error("Save failed: " + save_result.get_error())
