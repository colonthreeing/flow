class_name GraphNodeMaker extends RefCounted

static func coalesce(a, b):
	return a if a else b

static func generate_ui_item(comp: Dictionary, g: DynamicGraphNode, node_data : Dictionary = {}, allow_binding : bool = true):
	match comp.type:
			#! POTENTIAL REFACTOR: Use scenes instead of defining all through code
			"Label":
				var label = Label.new()
				
				if comp.has("text"):
					label.text = comp.text
				
				if comp.has("ports"): g.changed_ports.append({"node": label, "settings": comp.get("ports")})

				return label
			"TextEdit":
				var te = TextEdit.new()
				
				if comp.has("placeholder"):
					te.placeholder_text = comp.placeholder
				
				te.scroll_fit_content_height = true
				te.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
				
				# Doesn't seem to work currently 3:
				#te.grow_vertical = Control.GROW_DIRECTION_BOTH
				
				te.theme_type_variation = "SmallText"
				
				if allow_binding: g.bind_value(comp.name, te, "text")
				if node_data.has(comp.name): te.text = coalesce(node_data.get(comp.name), "")
				
				if comp.has("ports"): g.changed_ports.append({"node": te, "settings": comp.get("ports")})
				
				return te
				
				#te.text_changed.connect(func ():
					#print(g.evaluate_bound())
				#)
			"LineEdit":
				var le = LineEdit.new()
				
				if comp.has("placeholder"):
					le.placeholder_text = comp.placeholder
				
				le.theme_type_variation = "SmallText"
				
				if allow_binding: g.bind_value(comp.name, le, "text")
				if node_data.has(comp.name):
					le.text = coalesce(node_data.get(comp.name), "")
				
				if comp.has("ports"): g.changed_ports.append({"node": le, "settings": comp.get("ports")})

				return le

			"FileInput":
				var file_edit = NativeFileDialog.new()
				
				file_edit.file_mode = NativeFileDialog.FILE_MODE_OPEN_FILE
				
				if comp.has("filters"):
					if comp.filters is String:
						file_edit.set_filters(PackedStringArray([comp.filters]))
					elif comp.filters is Array:
						file_edit.set_filters(PackedStringArray(comp.filters))
				
				var btn = Button.new()
				
				btn.icon = ThemeSingleton.load_theme_icon("circle-plus.svg")
				
				
				btn.pressed.connect(file_edit.show)
				
				var le = LineEdit.new()
				le.placeholder_text = "Filepath..."
				
				le.theme_type_variation = "SmallText"
				le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				
				var hbc = HBoxContainer.new()
				hbc.add_child(le)
				hbc.add_child(btn)
				
				file_edit.file_selected.connect(func(file):
					le.text = file
				)

				var vbc = VBoxContainer.new()
				
				vbc.add_child(file_edit)
				vbc.add_child(hbc)
				
				
				if allow_binding: g.bind_value(comp.name, le, "text")
				if node_data.has(comp.name):
					le.text = coalesce(node_data.get(comp.name), "")

				if comp.has("ports"): g.changed_ports.append({"node": vbc, "settings": comp.get("ports")})

				return vbc
				
			"ImageInput":
				var file_edit = NativeFileDialog.new()
				
				file_edit.file_mode = NativeFileDialog.FILE_MODE_OPEN_FILE

				file_edit.set_filters(PackedStringArray(["*.bmp, *.dds, *.ktx, *.exr, *.hdr, *.jpg, *.jpeg, *.png, *.tga, *.svg, *.webp ; Supported image files"]))

				var btn = Button.new()
				
				btn.icon = ThemeSingleton.load_theme_icon("image-plus.svg")
				
				
				btn.pressed.connect(file_edit.show)
				
				var le = LineEdit.new()
				le.placeholder_text = "Filepath..."
				
				le.theme_type_variation = "SmallText"
				le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				
				var display = TextureRect.new()
				
				display.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
				display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				
				display.visible = false
				
				var hbc = HBoxContainer.new()
				hbc.add_child(le)
				hbc.add_child(btn)
				
				
				# Would love to use a function but when the lineedit is changed it can't set the text or it acts weird
				file_edit.file_selected.connect(func(file):
					if FileAccess.file_exists(file):
						display.visible = true
						display.texture = ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(file)))
					else:
						display.visible = false
					le.text = file
				)
				le.text_changed.connect(func(file):
					if FileAccess.file_exists(file):
						display.visible = true
						display.texture = ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(file)))
					else:
						display.visible = false

				)

				
				var vbc = VBoxContainer.new()
				
				vbc.add_child(file_edit)
				vbc.add_child(hbc)
				vbc.add_child(display)
				
				
				if allow_binding: g.bind_value(comp.name, le, "text")
				if node_data.has(comp.name):
					file_edit.emit_signal("file_selected", coalesce(node_data.get(comp.name), ""))
				
				if comp.has("ports"): g.changed_ports.append({"node": vbc, "settings": comp.get("ports")})

				return vbc
			"Dropdown":
				var dd = OptionButton.new()
				
				for val in NodePackSingleton.get_value_from_string(comp.enum):
					dd.add_item(val)
				
				if allow_binding: g.bind_value(comp.name, dd, "selected")
				if node_data.has(comp.name):
					dd.selected = coalesce(node_data.get(comp.name), 0)
				
				if comp.has("ports"): g.changed_ports.append({"node": dd, "settings": comp.get("ports")})
				
				return dd
			#"Container":
				#var vbox = VBoxContainer.new()
				#
				#if comp.has("children"):
					#for val in comp.children:
						#vbox.add_child(generate_ui_item(val, g, true))
				#
				#return vbox
			#"Creator":
				#"""
				#So:
					#- Need "children" to be individually made and attached directly to `g`
					  #so that they can have their own slot
				#"""
				#pass
			_:
				push_error("Unknown type passed: %s" % comp.type)
	
# Doesn't really need to be a function but fuck you
static func generate_ui(data: Dictionary, g: DynamicGraphNode, node_data = {}, allow_binding = true):
	g.node_type = data.name
	for comp in data.components:
		g.add_child(generate_ui_item(comp, g, node_data, allow_binding))
	
	for port in g.changed_ports:
		if port is Dictionary:
			g.change_ports(port.node, port.settings)

static func make_graph_node(data : Dictionary, node_data = {}, g : DynamicGraphNode = DynamicGraphNode.new()) -> DynamicGraphNode:
#	var g = DynamicGraphNode.new() # don't remember why I named this `g`. going to refactor in VSCode later?
	
	if data.has("name"):
		g.title = data.name
	
	if data.has("components"):
		generate_ui(data, g, node_data.get("data", {}))
	
#	g.set_slot_enabled_left(0, true)
#	g.set_slot_enabled_right(0, true)
	
	# g.set_slot(0, true, 0, Color.WHITE, true, 0, Color.WHITE)
	
	if node_data.has("id"):
		g.name = node_data.get("id")
	else:
		g.name = uuid.v4()
	
	if node_data == {}:
		g.node_data = g.serialize()
	
	return g

static func load_graph_node(node : DynamicGraphNode, data : Dictionary) -> DynamicGraphNode:
	var creation_data : Dictionary = NodePackSingleton.leaves[data.get("type", "")]
	
	var new_node = make_graph_node(creation_data, data, node)
	
	new_node.position_offset = data.get("position", Vector2(0,0))
	new_node.call_deferred("set_size", data.get("size", Vector2(180, 150))) # Doesn't work unless deferred

	return new_node
