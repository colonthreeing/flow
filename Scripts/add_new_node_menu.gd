extends VBoxContainer

@onready var tree : Tree = %Tree
@onready var search : LineEdit = %Search

var search_line : int = 0

signal requested_close
signal requested_new_node(filepath : String)


#TODO: Add this to `nodes` and update code
#enum node_types {
#	CATEGORY,
#	NODE
#}

var nodes_old = [
	{
		"type": "category",
		"name": "Dialogue",
		"tooltip": "Events that change the dialogue box (talking, etc)",
		"content": [
			{
				"type": "node",
				"name": "Talk",
				"tooltip": "Convenience event for changing text, author, and waiting for the next input.",
				"path": "res://GraphNodeTypes/Nodes/DialogueTalk.tscn"
			},
			{
				"type": "node",
				"name": "ChangeAuthorDirect",
				"tooltip": "Changes the text for the Author directly, skipping needing to use Talk.",
				"path": "res://GraphNodeTypes/Nodes/DialogueChangeAuthor.tscn"
			},
			{
				"type": "node",
				"name": "ChangeTextDirect",
				"tooltip": "Changes the text for the Dialogue directly, skipping needing to use Talk.",
				"path": "res://GraphNodeTypes/Nodes/DialogueChangeText.tscn"
			}
		]
	},
	{
		"type": "category",
		"name": "Display",
		"tooltip": "Events that change how the world is displayed",
		"content": [
			{
				"type": "node",
				"name": "ChangeSprite",
				"tooltip": "Changes the texture used for a given actor.",
			},
			{
				"type": "node",
				"name": "FlipCharacter",
				"tooltip": "Flips a character to make them look left/right.",
			},
			{
				"type": "node",
				"name": "MoveCharacter",
				"tooltip": "Moves a character on the screen to a new position.",
			},
		]
	},
	{
		"type": "category",
		"name": "Control",
		"tooltip": "Events that modify the game.",
		"content": [
			{
				"type": "node",
				"name": "Wait",
				"tooltip": "Pauses for the given amount of seconds.",
				"path": "res://GraphNodeTypes/Nodes/ControlWait.tscn"
			},
			{
				"type": "category",
				"name": "Testy Test",
				"content": [
					{
						"type": "node",
						"name": "Wait2",
						"tooltip": "Pauses for the given amount of seconds.",
						"path": "res://GraphNodeTypes/Nodes/ControlWait.tscn"
					},
				]
			}
		]
	}
]

var leaves : Array[TreeItem] = []

func construct_tree(root: TreeItem, data: Array) -> void:
	#for node : TreeNode in data:
		#var item : TreeItem = root.create_child()
		#item.set_text(0, node.node_name)
		#item.set_metadata(0, node)
		#item.set_tooltip_text(0, node.description)
		#
		#if node is TreeNodeCategory:
			#construct_tree(item, node.children)
		#elif node is TreeNodeResource:
			#leaves.append(item)

	for node : Dictionary in data:
		var item : TreeItem = root.create_child()
		item.set_text(0, node.name)
		item.set_metadata(0, node)
		if node.has("tooltip"):
			item.set_tooltip_text(0, node.tooltip)
		if node.type == "category":
			construct_tree(item, node.content)
		elif node.type == "node":
			leaves.append(item)
		else:
			push_error("Bad type supplied to construct_tree: ", node.type)


func _ready() -> void:
	var yml = YAML.load_file("res://NodePacks/visualnovel.yml")
	print(yml.get_data())
	
	var root = tree.create_item()
	root.set_metadata(0, {
		"type": "category",
		"name": "",
		"content": yml.get_data().nodes
	})
	
	construct_tree(root, yml.get_data().nodes)
	
	search.grab_focus()
	find_nth_leaf_item(0).select(0)
	


func path_contains(text: String, toplevel: TreeItem) -> bool:
	if toplevel.get_metadata(0):
		# print("%s contains %s: %s" % [toplevel.get_metadata(0).name.to_lower(), text, toplevel.get_metadata(0).name.to_lower().contains(text)])
		if toplevel.get_metadata(0).name.to_lower().contains(text):
			return true
	# print("No meta found for top level! ", toplevel.get_text(0))
	
	for child : TreeItem in toplevel.get_children():
		# print("%s : %s" % [child.get_metadata(0).name, child.get_metadata(0).name.to_lower().contains(text)])
		if child.get_metadata(0).name.to_lower().contains(text):
			# print("Returning true!")
			return true
		if child.get_metadata(0) is TreeNodeCategory:
			if path_contains(text, child):
				return true
	
	
	return false

func search_tree(text: String, toplevel: TreeItem = tree.get_root()) -> void:
	var should_be_visible : bool = false
	
	if toplevel.get_metadata(0).name.to_lower().contains(text):
		should_be_visible = true
		# return toplevel.get_metadata(0).name.to_lower().contains(text)
	
	for child : TreeItem in toplevel.get_children():
		if path_contains(text, child):
			should_be_visible = true

		search_tree(text, child)
		
	toplevel.visible = should_be_visible

func show_tree() -> void:
	tree.get_root().call_recursive("set_visible", true)

func appear():
	search.grab_focus()
	search.select_all()

func get_current_path() -> String:
	return tree.get_selected().get_metadata(0).scene

func find_nth_leaf_item(n: int) -> TreeItem:
	var visible_leaves : Array[TreeItem] = []
	for leaf : TreeItem in leaves:
		if leaf.visible: visible_leaves.append(leaf)
		leaf.deselect(0)
	
	if len(visible_leaves) == 0:
		return tree.get_root()
	
	return visible_leaves[wrap(n, 0, len(visible_leaves))]

func _on_tree_item_activated() -> void:
	var n = tree.get_selected().get_metadata(0)
	if n:
		emit_signal("requested_new_node", get_current_path())
		request_exit()

func request_exit() -> void:
	emit_signal("requested_close")

func _on_create_pressed() -> void:
	_on_tree_item_activated() # yeah whatever fuck you

func _on_tree_item_selected() -> void:
	if tree.get_selected().get_child_count() > 0:
		# probably ought to have gotten a static reference but who gives a shit
		$HBoxContainer/Create.disabled = true
	else:
		$HBoxContainer/Create.disabled = false

func _on_search_text_changed(new_text: String) -> void:
	show_tree()
	if new_text != "":
		search_tree(new_text.to_lower().replace(" ", ""))
	
	search_line = 0
	find_nth_leaf_item(0).select(0)

func _on_search_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_DOWN:
				search_line += 1
				accept_event()
			elif event.keycode == KEY_UP:
				search_line -= 1
				accept_event()
			elif event.keycode == KEY_ENTER:
				_on_create_pressed() # bad practice but FUCK YOU

			find_nth_leaf_item(search_line).select(0)
