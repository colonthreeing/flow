extends PanelContainer


signal delete_requested
signal new_node_requested

func _on_delete_pressed() -> void:
	emit_signal("delete_requested")

func _on_add_new_pressed() -> void:
	emit_signal("new_node_requested")
