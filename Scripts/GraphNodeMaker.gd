class_name GraphNodeMaker extends RefCounted

static func coalesce(a, b):
	return a if a else b

static func generate_ui_item(comp: Dictionary, g: DynamicGraphNode, binder: Callable, append_port : Callable, node_data : Dictionary = {}, allow_binding : bool = true):
	match comp.type:
			#! POTENTIAL REFACTOR: Use scenes instead of defining all through code
			"Label":
				var label = Label.new()
				
				if comp.has("text"):
					label.text = comp.text
				
				if comp.has("ports"): append_port.call({"node": label, "settings": comp.get("ports")})

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
				
				if allow_binding: binder.call(comp.name, te, "text")
				if node_data.has(comp.name): te.text = coalesce(node_data.get(comp.name), "")
				
				if comp.has("ports"): append_port.call({"node": te, "settings": comp.get("ports")})
				
				return te
				
				#te.text_changed.connect(func ():
					#print(g.evaluate_bound())
				#)
			"LineEdit":
				var le = LineEdit.new()
				
				if comp.has("placeholder"):
					le.placeholder_text = comp.placeholder
				
				le.theme_type_variation = "SmallText"
				
				if allow_binding: binder.call(comp.name, le, "text")
				if node_data.has(comp.name):
					var d = node_data.get(comp.name)
					if d and d is not String:
						d = var_to_str(d)
					le.text = coalesce(d, "")
				
				if comp.has("ports"):
					append_port.call({"node": le, "settings": comp.get("ports")})

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
				
				
				if allow_binding: binder.call(comp.name, le, "text")
				if node_data.has(comp.name):
					le.text = coalesce(node_data.get(comp.name), "")

				if comp.has("ports"): append_port.call({"node": vbc, "settings": comp.get("ports")})

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
				
				
				if allow_binding: binder.call(comp.name, le, "text")
				if node_data.has(comp.name):
					file_edit.emit_signal("file_selected", coalesce(node_data.get(comp.name), ""))
				
				if comp.has("ports"): append_port.call({"node": vbc, "settings": comp.get("ports")})

				return vbc
			"Dropdown":
				var dd = OptionButton.new()
				
				for val in NodePackSingleton.get_value_from_string(comp.enum):
					dd.add_item(val)
				
				if allow_binding: binder.call(comp.name, dd, "selected")
				if node_data.has(comp.name):
					dd.selected = coalesce(node_data.get(comp.name), 0)
				
				if comp.has("ports"): append_port.call({"node": dd, "settings": comp.get("ports")})
				
				return dd
			"Generator":
				# Holy shit this was complicated to make
				# But it turned out quite well, I think.
				var btn = Button.new()
				
				btn.icon = ThemeSingleton.load_theme_icon("circle-plus.svg")
				btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				
				btn.set_meta("created", 0)
				btn.set_meta("values", [])
				btn.set_meta("own_refs", [])
				
				var own_binder = func(_name, node, value):
					var meta = btn.get_meta("own_refs")
					meta.append({
						"referrer": node,
						"value": value
					})
				
				var generated_name = comp.component.get("name", "unknown")
				
				var remove_option = func(option: HBoxContainer):
					var ge: GraphEdit = g.get_parent()
					var cons = ge.connections.duplicate_deep()
					var removed_queue : Array[int] = []
					for connection_index in range(len(cons)):
						var connection = ge.connections[connection_index]
						if connection.from_node == g.name:
							var opt_index = option.get_index()
							if opt_index == connection.from_port:
								print("Removing item!!")
								removed_queue.append(connection_index)
								
								var new_refs = btn.get_meta("own_refs").duplicate_deep()
								
								for ref_i in range(len(new_refs)):
									# need to call get_parent because of the hbox
									if new_refs[ref_i].referrer.get_parent() == option:
										new_refs.remove_at(ref_i)
										btn.set_meta("own_refs", new_refs)
										break
								
								option.queue_free()
							elif opt_index < connection.from_port:
								cons[connection_index].from_port -= 1
					
					for i in removed_queue:
						cons.remove_at(i)
					
					ge.connections = cons
					
					ge.queue_redraw()
					ge.get_child(0, true).queue_redraw()
						
					"""
						if node == option and not changed:
							changed = true
							g.remove_child(node)
							
							if g.outports.has(index):
								#g.clear_slot(index)
								g.update_ports()
								var ge : GraphEdit = g.get_parent()
								var to_delete_index = 0
								for connection_index in range(len(ge.connections)):
									var connection = ge.connections[connection_index].duplicate_deep()
									if connection.from_node == g.name:
										print("%s : %s (%s)" % [connection.from_port, index, connection.from_port >= index])
										#print(connection)
										if connection.from_port == index - 1:
											# ge.connections.remove_at(connection_index)
											to_delete_index = connection_index
										elif connection.from_port > index - 1:
											connection.from_port -= 1
											ge.connections[connection_index] = connection
											#print(connection)
											#connection.from_port -= 1
											#ge.connections[connection_index] = connection
											#ge.queue_redraw()

								ge.connections.remove_at(to_delete_index)
								ge.queue_redraw()
								ge.get_child(0, true).queue_redraw()
								break

					g.update_ports()
					"""
				
				var create_option = func (local_node_data = null):
					for index in range(g.get_child_count()):
						if g.get_child(index) == btn:
							var new_comp = comp.get("component", {}).duplicate()

							var container = HBoxContainer.new()
							
							var c : Control = generate_ui_item(new_comp, g,
													own_binder, func(dict: Dictionary):
														dict.node = container
														append_port.call(dict)
														,
													{ generated_name : local_node_data })
							
							c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
							
							container.add_child(c)
							
							var close_button = Button.new()
							close_button.icon = ThemeSingleton.load_theme_icon("circle-x.svg")
							close_button.pressed.connect(func():
								print(container)
								print("Hello!")
								remove_option.call(container)
							)
							
							container.add_child(close_button)
							
							g.add_child(container)
							
							g.move_child(container, index)
							
							btn.set_meta("created", btn.get_meta("created") + 1)
							
							break
				
				if node_data.has(comp.name):
					for node in node_data.get(comp.name):
						create_option.call_deferred(node)
				
				btn.pressed.connect(func():
					g.call_deferred("update_ports")
					create_option.call()
				)
				
				if allow_binding:
					binder.call(
						comp.name,
						btn,
						func():
							var found := []
							
							for bound in btn.get_meta("own_refs"):
								found.append(
									g.evaluate_single_bound(
										bound
									)
								)
							
							return found
							
					)
				
				return btn

			_:
				push_error("Unknown type passed: %s" % comp.type)
	
# Doesn't really need to be a function but fuck you
static func generate_ui(data: Dictionary, g: DynamicGraphNode, node_data = {}, allow_binding = true):
	g.node_type = data.name
	var appender = func(value: Dictionary):
		g.changed_ports.append(value)
	
	for comp in data.components:
		g.add_child(generate_ui_item(comp, g, g.bind_value, appender, node_data, allow_binding))
	
	g.update_ports()
	#HACK fixes generators' ports not working
	g.call_deferred("update_ports")

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
	var creation_data : Dictionary = NodePackSingleton.leaves.get(data.get("type", ""), {})
	
#	if creation_data == null: return make_graph_node({}, {}, node)
	var new_node = make_graph_node(creation_data, data, node)
	
	new_node.position_offset = data.get("position", Vector2(0,0))
	new_node.call_deferred("set_size", data.get("size", Vector2(180, 150))) # Doesn't work unless deferred

	return new_node
