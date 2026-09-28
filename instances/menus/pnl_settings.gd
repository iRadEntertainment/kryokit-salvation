extends PanelContainer


@export var tabs_btn_group: ButtonGroup

@onready var tabs: TabContainer = %tabs


signal back_pressed


func _ready() -> void:
	tabs_btn_group.get_buttons()[tabs.current_tab].button_pressed = true
	tabs_btn_group.pressed.connect(_on_tabs_btn_group_pressed)


func _on_tabs_btn_group_pressed(btn: Button) -> void:
	var idx: int = btn.get_index()
	tabs.current_tab = idx


func _on_btn_back_pressed() -> void:
	Mng.settings.save()
	back_pressed.emit()
