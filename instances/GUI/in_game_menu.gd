extends Control


func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") or \
			event.is_action_pressed(&"pause_game"):
		visible = !visible
	if OS.has_feature("web"):
		if event is InputEventMouseButton:
			if not visible:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Mng.game.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		Mng.game.process_mode = Node.PROCESS_MODE_INHERIT


func _on_btn_continue_pressed() -> void:
	if OS.has_feature("web"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hide()


func _on_btn_settings_pressed() -> void:
	# TODO
	pass # Replace with function body.


func _on_btn_quit_to_title_pressed() -> void:
	Mng.go_to_title()
