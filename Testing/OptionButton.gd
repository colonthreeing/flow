extends Button

@export var option_number : int = 0


func _pressed() -> void:
	%FlowController.next(option_number)
