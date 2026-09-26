extends PanelContainer


signal back_pressed



func _on_btn_ok_pressed() -> void: back_pressed.emit()
