extends Node

func _ready() -> void:
	# Test if user data available:
#	if "projects" not in DirAccess.get_directories_at("user://"):
#		DirAccess.make_dir_absolute("user://projects/")
	pass

func make_project(project_name: String) -> void:
	pass

func save_project(graph: GraphEdit) -> void:
	var yml = YAML.new()
	
	

func export_project(graph: GraphEdit) -> void:
	pass
