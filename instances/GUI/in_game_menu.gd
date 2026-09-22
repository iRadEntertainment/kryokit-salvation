extends Control


func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		visible = !visible


func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Mng.game.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		Mng.game.process_mode = Node.PROCESS_MODE_INHERIT


#func toggle_mouse_mode() -> void:
	#if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#else:
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_btn_quit_to_title_pressed() -> void:
	Mng.go_to_title()
