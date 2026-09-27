class_name MainMenu
extends Control

@export var tab_button_group: ButtonGroup

@onready var tabs: TabContainer = %tabs
@onready var bg_blur: ColorRect = %bg_blur
@onready var btn_quit: Button = %btn_quit


func _ready() -> void:
	btn_quit.visible = not OS.has_feature("web")
	tabs.visibility_changed.connect(_on_tabs_visibility_changed)
	tabs.hide()
	tab_button_group.pressed.connect(_on_tab_button_group)
	#if not OS.is_debug_build():
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


func _on_tab_button_group(btn: Button) -> void:
	_tab_selected(btn.get_index())


func _on_tabs_visibility_changed() -> void:
	bg_blur.visible = tabs.visible


func _on_btn_quit_pressed() -> void: Mng.quit_game()
func _on_pnl_instructions_back_pressed() -> void: _tab_selected(0)
func _on_pnl_settings_back_pressed() -> void:_tab_selected(2)
