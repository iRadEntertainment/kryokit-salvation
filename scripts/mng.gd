# Singleton Game Manager class
extends Node


# self-registering
var game: Game
var gui: GUI
var hud: HUD
var forklift: Forklift

const SETTINGS_PATH: String = "user://settings.txt"
var settings: GameSettings


func _ready() -> void:
	settings = GameSettings.from_config_file(SETTINGS_PATH)
	settings.apply_audio_bus_volumes()


func go_to_title() -> void:
	get_tree().change_scene_to_file("uid://31e1t125m574")


func go_to_new_game() -> void:
	get_tree().change_scene_to_file("uid://4etuo4dq13m0")


func go_to_tutorial() -> void:
	get_tree().change_scene_to_file("uid://k4dekefb6nc3")


func quit_game() -> void:
	settings.save()
	get_tree().quit()
