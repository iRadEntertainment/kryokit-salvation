class_name Game
extends Node3D


func _init() -> void:
	Mng.game = self


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
