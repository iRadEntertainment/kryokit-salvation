@tool
extends HBoxContainer


@export var audio_bus: int = 0:
	set(value):
		audio_bus = value
		if not is_node_ready(): await ready
		lb_bus.text = _get_audio_bus_name()
@export var custom_name: String:
	set(value):
		custom_name = value
		if not is_node_ready(): await ready
		lb_bus.text = _get_audio_bus_name()

@onready var lb_bus: Label = $lb_bus
@onready var sl_volume: HSlider = $sl_volume
@onready var lb_volume: Label = $lb_volume


func _ready() -> void:
	_update()
	if not Engine.is_editor_hint():
		_connect_signals()


func _connect_signals() -> void:
	sl_volume.value_changed.connect(_on_sl_volume_value_changed)


func _update() -> void:
	sl_volume.value = AudioServer.get_bus_volume_linear(audio_bus)
	lb_volume.text = "%d%%" % (roundi(sl_volume.value * 100.0))


func _validate_property(property: Dictionary) -> void:
	if property.name == "audio_bus":
		var names := PackedStringArray()
		for i in AudioServer.bus_count:
			names.append(AudioServer.get_bus_name(i))

		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = ",".join(names)


func _get_audio_bus_name() -> String:
	if custom_name:
		return custom_name
	return AudioServer.get_bus_name(audio_bus)


func _on_sl_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(audio_bus, value)
	_update()
