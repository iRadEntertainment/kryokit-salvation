@tool
extends SpotLight3D

@export_group("Blinking")
@export var blink_enabled: bool = true
@export var blink_on_time: float = 0.5     # seconds ON
@export var blink_off_time: float = 0.5    # seconds OFF
@export var blink_random_delay: float = 0.15  # maximum random startup delay

@export_group("Rotation")
@export var rotation_enabled: bool = true
@export var rotation_speed: float = 45.0   # degrees per second
@export_enum("X", "Y", "Z") var rotation_axis: int = 1
@export var rotation_random_offset: float = 10.0 # maximum random rotation offset

var _blink_timer: float = 0.0
var _is_on: bool = true


func _ready() -> void:
	# Give every instance a different starting point for the blink cycle.
	if blink_enabled and blink_random_delay > 0.0:
		_blink_timer = randf_range(0.0, blink_random_delay)

	# Give every instance a slightly different starting rotation.
	if rotation_enabled and rotation_random_offset > 0.0:
		var random_angle := deg_to_rad(
			randf_range(-rotation_random_offset, rotation_random_offset)
		)

		match rotation_axis:
			0:
				rotate_x(random_angle)
			1:
				rotate_y(random_angle)
			2:
				rotate_z(random_angle)


func _process(delta: float) -> void:
	_handle_blink(delta)
	_handle_rotation(delta)


func _handle_rotation(delta: float) -> void:
	if not rotation_enabled or rotation_speed == 0.0:
		return

	var angle := deg_to_rad(rotation_speed) * delta

	match rotation_axis:
		0:
			rotate_x(angle)
		1:
			rotate_y(angle)
		2:
			rotate_z(angle)


func _handle_blink(delta: float) -> void:
	if not blink_enabled:
		visible = true
		return

	# Safety guard for editor tweaking
	if blink_on_time <= 0.0 or blink_off_time <= 0.0:
		visible = true
		return

	_blink_timer += delta

	if _is_on and _blink_timer >= blink_on_time:
		_is_on = false
		_blink_timer = 0.0
		visible = false

	elif not _is_on and _blink_timer >= blink_off_time:
		_is_on = true
		_blink_timer = 0.0
		visible = true
