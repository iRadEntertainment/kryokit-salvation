class_name Game
extends Node3D


@export var is_tutorial: bool = false


func _init() -> void:
	Mng.game = self


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
