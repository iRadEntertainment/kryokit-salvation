class_name MainMenu
extends Control


@onready var btn_quit: Button = %btn_quit


func _ready() -> void:
	btn_quit.visible = not OS.has_feature("web")
	if OS.is_debug_build():
		Aud.play_mus_title()


func _on_btn_start_pressed() -> void:
	Mng.go_to_new_game()


func _on_btn_quit_pressed() -> void:
	Mng.quit_game()


func _on_btn_setting_pressed() -> void:
	# TODO: popup settings
	pass # Replace with function body.
