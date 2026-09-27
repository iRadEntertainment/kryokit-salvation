extends Control


@onready var pnl_pause: PanelContainer = %pnl_pause
@onready var tabs: TabContainer = %tabs


func _ready() -> void:
	hide()
	pnl_pause.show()
	tabs.hide()
	tabs.visibility_changed.connect(_on_tabs_visibility_changed)
	visibility_changed.connect(_on_visibility_changed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		if tabs.visible:
			tabs.hide()
		else:
			visible = !visible
	
	# recapture the mouse on the web build
	if OS.has_feature("web"):
		if event is InputEventMouseButton:
			if not visible:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _toggle_tab_visibility(idx: int) -> void:
	if tabs.visible:
		if idx == tabs.current_tab:
			tabs.hide()
		else :
			tabs.current_tab = idx
	else:
		tabs.show()
		tabs.current_tab = idx


func _on_visibility_changed() -> void:
	# pause logic
	if is_visible_in_tree():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Mng.game.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		Mng.game.process_mode = Node.PROCESS_MODE_INHERIT


func _on_tabs_visibility_changed() -> void:
	pnl_pause.visible = !tabs.visible


func _on_btn_continue_pressed() -> void:
	# recapture the mouse on the web build
	if OS.has_feature("web"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hide()
func _on_btn_settings_pressed() -> void: _toggle_tab_visibility(0)
func _on_btn_instructions_pressed() -> void: _toggle_tab_visibility(1)
func _on_btn_quit_to_title_pressed() -> void: Mng.go_to_title()

func _on_pnl_settings_back_pressed() -> void: tabs.hide()
func _on_pnl_instructions_back_pressed() -> void: tabs.hide()
