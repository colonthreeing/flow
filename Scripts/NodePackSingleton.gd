extends Node

var data = {}

var vars = {
	"authors": {
		"type": "enum",
		"value": ["Vagabond", "Colon", "Three"],
	}
}

var enums = {}

func _init() -> void:
	data = YAML.load_file("res://NodePacks/visualnovel.yml").get_data()

func get_value_from_string(str: String):
	var s = str.split("/")
	
	match s[0]:
		"vars":
			return vars[s[1]].value
		"enums":
			return vars[s[1]].value
		_:
			push_warning("get_value_from_string passed bad value '%s'!" % str)
			return {} # So shit doesn't hit the fan (what a weird expression)
