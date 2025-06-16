class_name GraphNodeMaker extends RefCounted

static func generate_ui_item(comp: Dictionary, g, allow_binding = true):
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
				
				if allow_binding: g.bind_value(comp.name, te, "text")
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
				return vbc
			"Dropdown":
				var dd = OptionButton.new()
				
				for val in NodePackSingleton.get_value_from_string(comp.enum):
					dd.add_item(val)
				
				if allow_binding: g.bind_value(comp.name, dd, "selected")
				return dd
			"Container":
				var vbox = VBoxContainer.new()
				
				if comp.has("children"):
					for val in comp.children:
						vbox.add_child(generate_ui_item(val, g, true))
				
				return vbox
			"Creator":
				"""
				So:
					- Need "children" to be individually made and attached directly to `g`
					  so that they can have their own slot
				"""
				pass
			_:
				print("Unknown type passed: %s" % comp.type)

static func generate_ui(data: Dictionary, g, allow_binding = true):
	for comp in data.components:
		g.add_child(generate_ui_item(comp, g, true))

static func make_graph_node(data : Dictionary) -> GraphNode:
	var g = DynamicGraphNode.new() # don't remember why I named this `g`. going to refactor in VSCode later?
	
	if data.has("name"):
		g.title = data.name
	
	if data.has("components"):
		generate_ui(data, g)
	
	var btn = Button.new()
	
	btn.pressed.connect(func():
		print(g.evaluate_bound())
	)
	
	btn.text = "Test Export"
	
	g.add_child(btn)
	
	return g
