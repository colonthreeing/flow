class_name DynamicGraphNode extends GraphNode

var bound_data = {}

func _ready() -> void:
	custom_minimum_size = Vector2(120, 0)
	size.x = 180
	resizable = true

func evaluate_bound() -> Dictionary:
	var evaluated = {}
	
	for bound_key : StringName in bound_data:
		var bound = bound_data[bound_key]
		evaluated[bound_key] = bound.referrer.get(bound.value)
	
	return evaluated

func bind_value(bound_name: StringName, node: Node, value: StringName):
	bound_data[bound_name] = {
		"referrer": node,
		"value": value
	}
