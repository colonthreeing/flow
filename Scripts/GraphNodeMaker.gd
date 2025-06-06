class_name GraphNodeMaker extends RefCounted

static func make_graph_node(data : Dictionary) -> GraphNode:
	var g = DynamicGraphNode.new()
	
	if data.has("name"):
		g.title = data.name
	
	if data.has("components"):
		for comp in data.components:
			match comp.type:
				#! FUTURE REFACTOR: Use scenes instead of defining all through code
				"TextEdit":
					var te = TextEdit.new()
					
					if comp.has("placeholder"):
						te.placeholder_text = comp.placeholder
					
					te.scroll_fit_content_height = true
					te.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
					
					# Doesn't seem to work currently 3:
					#te.grow_vertical = Control.GROW_DIRECTION_BOTH
					
					te.theme_type_variation = "SmallText"
					
					g.add_child(te)
					g.bind_value(comp.name, te, "text")
					
					#te.text_changed.connect(func ():
						#print(g.evaluate_bound())
					#)
				"LineEdit":
					var le = LineEdit.new()
					
					if comp.has("placeholder"):
						le.placeholder_text = comp.placeholder
					
					le.theme_type_variation = "SmallText"
					
					g.add_child(le)
					g.bind_value(comp.name, le, "text")
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
					
					g.add_child(vbc)
					
					g.bind_value(comp.name, le, "text")
					
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
					
					var hbc = HBoxContainer.new()
					hbc.add_child(le)
					hbc.add_child(btn)
					
					var on_change = func(file):
						le.text = file
						if FileAccess.file_exists(file):
							display.texture = ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(file)))
					
					file_edit.file_selected.connect(on_change)
					le.text_changed.connect(on_change)

					
					var vbc = VBoxContainer.new()
					
					vbc.add_child(file_edit)
					vbc.add_child(hbc)
					vbc.add_child(display)
					
					g.add_child(vbc)
					
					g.bind_value(comp.name, le, "text")
				"Dropdown":
					var dd = OptionButton.new()
					
					for val in NodePackSingleton.get_value_from_string(comp.enum):
						dd.add_item(val)
					
					g.add_child(dd)
					g.bind_value(comp.name, dd, "selected")
				_:
					print("Unknown type passed: %s" % comp.type)
	var btn = Button.new()
	
	btn.pressed.connect(func():
		print(g.evaluate_bound())
	)
	
	btn.text = "Test Export"
	
	g.add_child(btn)
	
	return g
