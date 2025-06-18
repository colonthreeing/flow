class_name DynamicGraphNode extends GraphNode

var bound_data = {}
var node_type = ""

func _init() -> void:
	pass

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

func _draw_port(slot_index: int, position: Vector2i, left: bool, color: Color) -> void:
	"""
	Slot slot = slot_table[p_slot_index];
	Ref<Texture2D> port_icon = p_left ? slot.custom_port_icon_left : slot.custom_port_icon_right;

	Point2 icon_offset;
	if (port_icon.is_null()) {
		port_icon = theme_cache.port;
	}

	icon_offset = -port_icon->get_size() * 0.5;
	port_icon->draw(get_canvas_item(), p_pos + icon_offset, p_color);
	"""
	
	draw_circle(position, 7, color, true, -1.0, true)
	var stylebox = get_theme_stylebox("panel_selected") if selected else get_theme_stylebox("panel")
	if stylebox is StyleBoxFlat:
		draw_circle(position, 8, stylebox.border_color, false, 1.0, true)

func serialize() -> Dictionary:
	return {
		"type": node_type,
		"position": position_offset,
		"data": evaluate_bound(),
	}

static func deserialize(data: Dictionary) -> DynamicGraphNode:
	return DynamicGraphNode.new()
