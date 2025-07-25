class_name DynamicGraphNode extends GraphNode

var bound_data = {}
var node_type = ""

var node_data = {}
var changed_ports = []
var outports = []

func _init(p_node_data : Dictionary = {}) -> void:
	node_data = p_node_data

func _ready() -> void:
	custom_minimum_size = Vector2(120, 0)
	size.x = 180
	resizable = true

func evaluate_bound(bd = bound_data) -> Dictionary:
	var evaluated = {}
	
	for bound_key : StringName in bd:
		var bound = bound_data[bound_key]
		evaluated[bound_key] = evaluate_single_bound(bound)
	return evaluated

func evaluate_single_bound(bound) -> Variant:
	var evaluated
	if bound.value is Callable:
		evaluated = bound.value.call()
	else:
		evaluated = bound.referrer.get(bound.value)
	
	return evaluated

func bind_value(bound_name: StringName, node: Node, value: Variant):
	bound_data[bound_name] = {
		"referrer": node,
		"value": value
	}

# WARNING dead code, saving in case i need later
func unbind_node(node: Node):
	for bound_k in bound_data:
		print("%s : %s" % [bound_data.get(bound_k), node])
		if bound_data.get(bound_k).referrer == node:
			bound_data.erase(bound_k)
			break

func update_ports():
	outports = []
	clear_all_slots()
	for port in changed_ports:
		if port is Dictionary:
			change_ports(port.node, port.settings)

func change_ports(node : Node, ports : Dictionary):
	# This is objectively shitty coding *but* it works decently well
	# And I'm not really sure how I would fix it.
	# Submit a PR if you feel like it and I'll probably merge it.
	for child_idx in get_child_count():
		if get_child(child_idx) == node:
			var left = ports.get("left")
			var right = ports.get("right")
			if left is bool:
				set_slot_enabled_left(child_idx, left)
#				set_slot_enabled_left(0, true)
			elif left is Dictionary:
				# lowkey ts pmo sm (/hj) since it needs to be there in case the slot is enabled
				# but either of these aren't defined
				# as otherwise it errors and doesn't make the slot work correctly.
				if left.get("enabled") == true:
					set_slot_enabled_left(child_idx, true)
					if left.get("color") is Color:
						set_slot_color_left(child_idx, left.get("color"))
					if left.get("type") is int:
						set_slot_type_left(child_idx, left.get("type"))
			if right is bool:
				set_slot_enabled_right(child_idx, right)
				if right: outports.append(child_idx)
			elif right is Dictionary:
				# lowkey ts pmo sm (/hj) since it needs to be there in case the slot is enabled
				# but either of these aren't defined
				# as otherwise it errors and doesn't make the slot work correctly.
				if right.get("enabled") == true:
					set_slot_enabled_right(child_idx, true)
					outports.append(child_idx)
					if right.get("color") is Color:
						set_slot_color_left(child_idx, right.get("color"))
					if right.get("type") is int:
						set_slot_type_left(child_idx, right.get("type"))
			break

func _draw_port(_slot_index: int, pos: Vector2i, _left: bool, color: Color) -> void:
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
	
	draw_circle(pos, 7, color, true, -1.0, false)
	var stylebox = get_theme_stylebox("panel_selected") if selected else get_theme_stylebox("panel")
	if stylebox is StyleBoxFlat:
		draw_circle(pos, 8, stylebox.border_color, false, 1.0, true)

func serialize() -> Dictionary:
	return {
		"type": node_type,
		"position": position_offset,
		"size": size,
		"id": name, # ID and node name is the same
		"data": evaluate_bound(),
	}

static func deserialize(data: Dictionary) -> DynamicGraphNode:
	return DynamicGraphNode.new(data)

func find_connection(index, connections):
	for connection in connections:
		if connection.from_node == name and connection.from_port == index:
			return connection

func make_flow_node() -> FlowNode:
	# First need to update own data
	node_data.data = evaluate_bound()
	
	var fn := FlowNode.new()
	
	fn.id = node_data.id
	fn.type = node_data.type
	fn.data = node_data.data
	
	#! Bad practice but this is how I want to do it
	var all_ports = get_parent().connections
	for own_port_idx in range(len(outports)):
		var con = find_connection(own_port_idx, all_ports)
		if con:
			fn.connections.append(con.to_node)
		else:
			fn.connections.append(&"") # So the indexes are still the same
	
	return fn

func build() -> void:
	for child in get_children():
		child.queue_free()
	GraphNodeMaker.load_graph_node(self, node_data)

func get_builder_data() -> Dictionary:
	return NodePackSingleton.leaves.get(node_data.get("type", ""), {})
