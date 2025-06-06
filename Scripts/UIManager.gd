extends Control


@onready var rightMenu : PanelContainer = %RightClickMenu
@onready var graph : GraphEdit = %GraphEdit
@onready var newNodePopup : PopupPanel = %AddNewNodeMenuPopup
@onready var nodeMenu : VBoxContainer = %NewNodeMenu

var requested_node_position : Vector2

var moving_nodes : bool = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			close_rightclick_menu()
			if moving_nodes:
				moving_nodes = false
			else:
				accept_event()
	elif event is InputEventMouseMotion:
		if moving_nodes:
			for node : GraphNode in graph.get_selected_nodes():
				node.position_offset += event.relative / graph.zoom

func _shortcut_input(event: InputEvent) -> void:
	var focused = get_viewport().gui_get_focus_owner()
	if (focused is not LineEdit) and (focused is not TextEdit):
		if event.is_action_pressed("RequestNewNode"):
			# print("Requested new node...")
			show_new_node_menu()
			accept_event()
		elif event.is_action_pressed("SortNodes") and len(graph.get_selected_nodes()) > 0:
			graph.arrange_nodes()
			accept_event()
		elif event.is_action_pressed("MoveNode") and len(graph.get_selected_nodes()) > 0:
			moving_nodes = not moving_nodes
			print("Moving!")
			accept_event()

func show_rightclick_menu(pos: Vector2):
	rightMenu.visible = true
	rightMenu.position = pos

func close_rightclick_menu():
	rightMenu.visible = false

func _on_right_click_menu_new_node_requested() -> void:
	close_rightclick_menu()
	show_new_node_menu()

func _on_right_click_menu_delete_requested() -> void:
	close_rightclick_menu()

func show_new_node_menu():
	#BUG graph.get_local_mouse_position() is always (0,0) until mouse is moved
	# Shouldn't make any difference for most people though.
	# Honestly, probably a Hyprland thing, not a Godot thing.
	requested_node_position = (graph.get_local_mouse_position() + graph.scroll_offset) / graph.zoom
	newNodePopup.show()
	nodeMenu.appear()

func close_new_mode_menu():
	newNodePopup.hide()

func _on_requested_new_node(data : Dictionary) -> void:
	var new_node : GraphNode = GraphNodeMaker.make_graph_node(data)
	
	new_node.position_offset = requested_node_position - Vector2(new_node.size.x / 2.0, 10.0)
	graph.add_child(new_node)

func _ready() -> void:
	graph.grab_focus()
