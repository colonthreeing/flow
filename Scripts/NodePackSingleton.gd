extends Node

var data = {}

var leaves = {}

var vars = {}

var enums = {}

func find_leaves(arr: Array):
	for dict in arr:
		if dict.get("type", "") == "node":
			leaves[dict.name] = dict
		else:
			if dict.has("content"):
				find_leaves(dict.get("content", []))

func _init() -> void:
	data = YAML.load_file("res://NodePacks/visualnovel.yml").get_data()
	
	find_leaves(data.get("nodes", []))
	
#	print(YAML.stringify(leaves).get_data())

func get_value_from_string(str: String):
	var s = str.split("/")
	
	match s[0]:
		"vars":
			return vars[s[1]].get("values")
		"enums":
			return vars[s[1]].get("values")
		_:
			push_warning("get_value_from_string passed bad value '%s'!" % str)
			return {} # So shit doesn't hit the fan (what a weird expression)
