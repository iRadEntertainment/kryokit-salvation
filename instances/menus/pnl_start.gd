extends PanelContainer


func _on_btn_start_pressed() -> void:
	Mng.go_to_new_game()


func _on_btn_tutorial_pressed() -> void:
	Mng.go_to_tutorial()
