extends GraphEdit

var selected_nodes := {}

var copied_nodes : Array[GraphNode] = []

func _ready() -> void:
	show_menu = false

func add_node(pos: Vector2, title: String):
	var node := GraphNode.new()
	add_child(node)
	node.position_offset = pos
	node.title = title

func _on_connection_request(from_node, from_port, to_node, to_port):
	connect_node(from_node, from_port, to_node, to_port)

func _on_disconnection_request(from_node, from_port, to_node, to_port):
	disconnect_node(from_node, from_port, to_node, to_port)

func _on_delete_nodes_request(_nodes: Array[StringName]) -> void:
	print("Deleting!")
	for node in selected_nodes.keys():
		if selected_nodes[node]:
			remove_connections_to_node(node) # probably not needed but the gdscript.com tutorial has it so who cares
			node.queue_free()

	selected_nodes = {}

func _on_node_selected(node: Node) -> void:
	selected_nodes[node] = true

func _on_node_deselected(node: Node) -> void:
	selected_nodes[node] = false

func remove_connections_to_node(node):
	for con in get_connection_list():
		if con.to_node == node.name or con.from_node == node.name:
			disconnect_node(con.from_node, con.from_port, con.to_node, con.to_port)


func _on_copy_nodes_request() -> void:
	for node in selected_nodes:
		pass

func get_selected_nodes() -> Array[GraphElement]:
	var r : Array[GraphElement] = []
	for node : GraphNode in selected_nodes:
		if selected_nodes[node]:
			r.append(node)
	
	return r

func find_node_with_property(prop_name : String, prop_value : Variant):
	if prop_value == not null:
		for node in get_children():
			if node is not DynamicGraphNode: continue
			if node.get_builder_data().get(prop_name) == prop_value:
				return node
	else:
		for node : DynamicGraphNode in get_children():
			if node.get_builder_data().has(prop_name):
				return node
