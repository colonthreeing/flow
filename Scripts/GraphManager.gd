extends GraphEdit


signal right_clicked
signal left_clicked

var selected_nodes := {}

var copied_nodes : Array[GraphNode] = []

func add_node(pos: Vector2, title: String):
	var node := GraphNode.new()
	add_child(node)
	node.position_offset = pos
	node.title = title

#func _input(event: InputEvent) -> void:
	#if event is InputEventKey:
		#pass
##		if event.keycode == KEY_A and event.pressed:
##			add_node(get_viewport().get_mouse_position() + scroll_offset, "New Node")
##			accept_event()
	#elif event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			#emit_signal("right_clicked")
		#elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#emit_signal("left_clicked")

#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#emit_signal("left_clicked")

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
		print(con)
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
