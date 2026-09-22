extends Camera3D


@export var target: Node3D


func _ready() -> void:
	if target:
		look_at(target.global_position)


func _process(_delta: float) -> void:
	if not target:
		set_process(false)
		return
	look_at(target.global_position)


func _input(event: InputEvent) -> void:
	if not target:
		return
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	if event is InputEventMouseMotion:
		var cam_shift: Vector2 = event.relative / get_window().size.y
		global_position -= global_transform.basis.x * cam_shift.x * 2.0
		global_position += global_transform.basis.y * cam_shift.y * 2.0
	elif event is InputEventMouseButton:
		if event.is_released(): return
		var zoom_input: float = 0.0
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP: zoom_input = -1.0
			MOUSE_BUTTON_WHEEL_DOWN: zoom_input = 1.0
		if not zoom_input:
			return
		var dist_to_targ: float = global_position.distance_to(target.global_position)
		global_position += global_transform.basis.z * 0.15 * dist_to_targ * zoom_input
