# Singleton Game Manager class
extends Node


# self-registering
var game: Game
var gui: GUI
var hud: HUD
var forklift: Forklift



func go_to_title() -> void:
	get_tree().change_scene_to_file("uid://31e1t125m574")


func go_to_new_game() -> void:
	get_tree().change_scene_to_file("uid://4etuo4dq13m0")


func quit_game() -> void:
	get_tree().quit()
