@tool

class_name Shelve
extends StaticBody3D

@export_tool_button("Generate")
@warning_ignore("unused_private_class_variable")
var _btn_generate: Callable = _generate_in_engine

@export var horiz_spots: Array[int] = [3]


const POSTS_MESH_INSTANCE = preload("res://blend/caged_hanging_light_1k.glb")


func _generate_in_engine() -> void:
	pass
