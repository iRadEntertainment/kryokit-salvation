class_name MainMenu
extends Control


@onready var tabs: TabContainer = %tabs
@onready var btn_quit: Button = %btn_quit


func _ready() -> void:
	btn_quit.visible = not OS.has_feature("web")
	tabs.hide()
	if OS.is_debug_build():
		Aud.play_mus_title()


func _tab_selected(idx: int) -> void:
	if tabs.visible:
		if tabs.current_tab == idx:
			tabs.hide()
		else:
			tabs.current_tab = idx
	else:
		tabs.show()
		tabs.current_tab = idx


func _on_btn_start_pressed() -> void: _tab_selected(0)
func _on_btn_quit_pressed() -> void: Mng.quit_game()
func _on_btn_setting_pressed() -> void: pass
func _on_btn_instructions_pressed() -> void: _tab_selected(1)
func _on_pnl_instructions_back_pressed() -> void: _tab_selected(0)
