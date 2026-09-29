class_name GameCamera
extends Camera3D


enum Mode{
	FPS,
	VEHICLE,
	FORK_ORBIT,
	TOP_DOWN,
}

var mode: Mode: set = _set_mode

var target: Node3D:
	set(value):
		target = value
		set_process(target != null)
		if target:
			if target.get_parent() is SpringArm3D:
				_spring_arm = target.get_parent()
			else:
				_spring_arm = null
		else:
			_spring_arm = null
var _spring_arm: SpringArm3D

var can_orbit: bool
var can_zoom: bool

var forklift: Forklift:
	get: return Mng.forklift


func _init() -> void:
	Mng.cam = self


func _ready() -> void:
	mode = Mode.VEHICLE
	set_process(target != null)


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	if not forklift.is_node_ready():
		await forklift.ready
	
	match mode:
		Mode.VEHICLE:
			target = forklift.cam_vehicle_target
			can_orbit = true
			can_zoom = true
		Mode.FORK_ORBIT:
			target = forklift.cam_fork_target
			can_orbit = true
			can_zoom = true
		Mode.TOP_DOWN:
			target = forklift.cam_top_target
			can_orbit = false
			can_zoom = true


func _process(delta: float) -> void:
	if not target:
		set_process(false)
		return
	
	_interpolate_with_transform(target.global_transform, delta * 8.0)


func _interpolate_with_transform(xform: Transform3D, speed: float = 8.0) -> void:
	global_transform = global_transform.interpolate_with(xform, speed)


func _input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	if event.is_action_pressed(&"cam_vehicle"): mode = Mode.VEHICLE
	elif event.is_action_pressed(&"cam_fork"): mode = Mode.FORK_ORBIT
	elif event.is_action_pressed(&"cam_top"): mode = Mode.TOP_DOWN
	
	if not target:
		return
	
	if _spring_arm:
		if event is InputEventMouseMotion and can_orbit:
			var cam_shift: Vector2 = event.relative / get_window().size.y
			_spring_arm.rotation.x -= cam_shift.y
			_spring_arm.rotation.y -= cam_shift.x
			
		elif event is InputEventMouseButton and can_zoom:
			if event.is_released(): return
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP:
					_spring_arm.spring_length *= 0.85
					_spring_arm.spring_length = max(_spring_arm.spring_length, 0.3)
				MOUSE_BUTTON_WHEEL_DOWN:
					_spring_arm.spring_length *= 1.15
					_spring_arm.spring_length = min(_spring_arm.spring_length, 15.0)
