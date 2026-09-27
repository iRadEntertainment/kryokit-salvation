@tool
extends PanelContainer

@export_custom(PROPERTY_HINT_INPUT_NAME, "Action") var action: StringName:
	set(value):
		action = value
		if Engine.is_editor_hint() and is_node_ready():
			_update_label()
@export var label_normal_color: Color = Color(0.62, 0.741, 0.878, 1.0)
@export var label_press_color: Color = Color(0.008, 0.216, 0.314, 1.0)

@onready var label: Label = $Label
@onready var highlight: Panel = $highlight


var pressed: bool: set = _set_pressed


func _ready() -> void:
	_update_label()


func _update_label() -> void:
	if not action:
		return
	label.text = get_label_from_event_action(action).left(3).to_upper()


func _input(event: InputEvent) -> void:
	if event.is_action(action):
		pressed = event.is_pressed()


func get_label_from_event_action(stringname: StringName) -> String:
	var events: Array
	if Engine.is_editor_hint():
		var dict: Dictionary = (ProjectSettings.get("input/%s" % stringname))
		events = dict.events
	else:
		events = InputMap.action_get_events(action)
	
	var e: InputEventKey = events.back()
	var key: Key = DisplayServer.keyboard_get_label_from_physical(e.physical_keycode)
	return OS.get_keycode_string(key)


func _set_pressed(value: bool) -> void:
	pressed = value
	label.modulate = label_press_color if pressed else label_normal_color
	highlight.visible = pressed
