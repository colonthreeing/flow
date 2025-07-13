## Helper abstract class for executing an Event.
@abstract class_name FlowController extends Node

var event : FlowEvent
var current_node : FlowNode

@abstract func next(port: int) -> void

func load_event(new_event : FlowEvent) -> void:
	event = new_event
	current_node = event.start

func get_node_by_id(id: StringName):
	for node : FlowNode in event.nodes:
		if node.id == id:
			return node
	if event.start.id == id: return event.start

## Updates current_node to be the next node, from its port.
func go_from_port(from_port : int):
	var id = current_node.connections.get(from_port)
	var node = get_node_by_id(id)
	if node:
		current_node = node
	else:
		push_error("Passed bad ID %s!" % [id])
