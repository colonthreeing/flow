class_name GraphNodeMaker extends RefCounted

static func make_graph_node(data : Dictionary) -> GraphNode:
	var g = DynamicGraphNode.new()
	
	if data.has("name"):
		g.title = data.name
	
	if data.has("components"):
		for comp in data.components:
			match comp.type:
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
					g.bind_value("dialogue", te, "text")
					
					#te.text_changed.connect(func ():
						#print(g.evaluate_bound())
					#)
				"LineEdit":
					pass
				"FileInput":
					pass
				"ImageInput":
					pass
				"Dropdown":
					var dd = OptionButton.new()
					
					for val in NodePackSingleton.get_value_from_string(comp.enum):
						dd.add_item(val)
					
					g.add_child(dd)
					g.bind_value("selected", dd, "selected")
				_:
					print("Unknown type passed: %s" % comp.type)
#			g.add_child(LineEdit.new())
	
	return g
