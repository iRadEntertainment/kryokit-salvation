class_name Forklift extends Node3D



@export var reset_raise: float = 0.20 #m from the horizontal plane

@export_group("Drive")
@export var throttle_max_power: float = 3000.0
@export var brake_max_force: float = 50.0
@export var brake_min_force: float = 5.5
@export_range(0.1, 5.0, 0.01) var steering_speed: float = 1.8
@export_range(1, 5, 1) var steering_snap_division: int = 3

@export_group("Mast")
@export var mast_tilt_speed: float = 0.15 #degrees/s
@export var mast_tilt_max: float = 2.5 #degrees
@export var mast_tilt_min: float = -4.5 #degrees

@export_group("Lift")
@export var lift_min_height: float = -0.03 #m
@export var lift_max_height: float = 5.40 #m
@export var lift_max_speed: float = 0.45 #m/s
@export var lift_max_force: float = 5000.0 # N, initial test value

@export_group("Fork")
@export var fork_max_width: float = 0.75 #m between fork centers
@export var fork_min_width: float = 0.25 #m between fork centers
@export var fork_shift_speed: float = 0.20 #m/s
@export var fork_widen_speed: float = 0.10 #m/s
@export var fork_motor_max_force: float = 2000.0


@onready var vehicle_body: VehicleBody3D = %vehicle_body
@onready var mast_body: RigidBody3D = %mast_body
@onready var carriage_body: RigidBody3D = %carriage_body
@onready var fork_l_body: RigidBody3D = %fork_l_body
@onready var fork_r_body: RigidBody3D = %fork_r_body

@onready var rear_wheel_visual_pivot: Node3D = %SteeringPivot
@onready var thrust_wheel: Node3D = %thrust_wheel
@onready var wheel_thrust: VehicleWheel3D = %wheel_thrust

@onready var mast_1: Node3D = %mast_1
@onready var mast_2: Node3D = %mast_2
@onready var mast_coll_extension: CollisionShape3D = %mast_coll_extension


@onready var joint_mast: Generic6DOFJoint3D = %joint_mast
@onready var joint_carriage: Generic6DOFJoint3D = %joint_carriage
@onready var joint_fork_l: Generic6DOFJoint3D = %joint_fork_l
@onready var joint_fork_r: Generic6DOFJoint3D = %joint_fork_r

@onready var text_nfo: TextEdit = %text_nfo

#Audio
@onready var sfx_engine_loop: AudioStreamPlayer3D = %sfx_engine_loop
@onready var sfx_mast_loop: AudioStreamPlayer3D = %sfx_mast_loop
@onready var sfx_mast_clunk: AudioStreamPlayer3D = %sfx_mast_clunk

#Camera
@onready var fork_focus: RemoteTransform3D = %fork_focus
@onready var cam_vehicle_target: Marker3D = %cam_vehicle_target
@onready var cam_fork_target: Marker3D = %cam_fork_target
@onready var cam_top_target: Marker3D = %cam_top_target


var PI_half: float = PI/2.0
var PI_quarter: float = PI/4.0
var settings: GameSettings:
	get: return Mng.settings

# movement
var current_speed: float:
	get: return vehicle_body.linear_velocity.length_squared()
var target_steering: float = 0.0
var _target_throttle: float = 0.0
var _wrapped_steering: float = 1
var _throttle_dir: int = 1


# mast and fork getters
var lift_height: float: get = get_lift_height
var mast_tilt: float: get = get_mast_tilt_rad
var mast_tilt_degree: float: get = get_mast_tilt_degree
var fork_l_position: float:
	get: return carriage_body.to_local(fork_l_body.global_position).x
var fork_r_position: float:
	get: return carriage_body.to_local(fork_r_body.global_position).x
var fork_shift: float:
	get: return (fork_l_position + fork_r_position) * 0.5
var fork_width: float:
	get: return fork_r_position - fork_l_position


# Inputs and input accellerations
var _drive_input: float:
	get: return Input.get_axis(&"back", &"forward")
var steering_acc: float
var steer_input: float:
	get: return -Input.get_axis(&"steer_left", &"steer_right")
var _lift_acc: float
var _lift_input: float:
	get: return Input.get_axis(&"lower_fork", &"lift_fork")
var _target_lift: float
var _tilt_acc: float
var _tilt_input: float:
	get: return Input.get_axis(&"tilt_backward", &"tilt_forward")
var _target_tilt: float
var _shift_acc: float
var _shift_input: float:
	get: return Input.get_axis(&"shift_fork_right", &"shift_fork_left")
var _target_shift: float
var _widen_input: float:
	get: return Input.get_axis(&"shrink_fork", &"widen_fork")
var _target_width: float


# States
var _mast_coll_extension_start_y_pos: float
var _engine_audio_volume: float = 0.0


func _init() -> void:
	Mng.forklift = self


func _ready() -> void:
	_setup_lift()
	_setup_tilt()
	_setup_fork()


func _on_audio_accel_finished() -> void:
	# Once the ramp-up sound finishes, switch to the continuous loop if still moving/accelerating
	var is_accelerating: bool = abs(_drive_input) > 0.01
	if is_accelerating or vehicle_body.linear_velocity.length() > 0.5:
		if not sfx_engine_loop.playing:
			sfx_engine_loop.play()


func _setup_lift() -> void:
	_mast_coll_extension_start_y_pos = mast_coll_extension.position.y
	joint_carriage.set_param_x(
		Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT,
		lift_min_height
	)
	joint_carriage.set_param_x(
		Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT,
		lift_max_height
	)
	joint_carriage.set_param_x(
		Generic6DOFJoint3D.PARAM_LINEAR_MOTOR_FORCE_LIMIT,
		lift_max_force
	)
	_target_lift = lift_min_height


func _setup_tilt() -> void:
	joint_mast.set_param_x(
		Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT,
		deg_to_rad(mast_tilt_min)
	)
	joint_mast.set_param_x(
		Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT,
		deg_to_rad(mast_tilt_max)
	)
	_target_tilt = mast_tilt_max


func _setup_fork() -> void:
	var rail_half_width := fork_max_width * 0.5
	var fork_l_x := carriage_body.to_local(fork_l_body.global_position).x
	var fork_r_x := carriage_body.to_local(fork_r_body.global_position).x
	
	_target_shift = 0.0
	_target_width = 0.35
	
	joint_fork_l.set_param_x(
		Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT,
		-rail_half_width - fork_l_x
	)
	joint_fork_l.set_param_x(
		Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT,
		rail_half_width - fork_l_x
	)
	
	joint_fork_r.set_param_x(
		Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT,
		-rail_half_width - fork_r_x
	)
	joint_fork_r.set_param_x(
		Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT,
		rail_half_width - fork_r_x
	)
	
	for joint: Generic6DOFJoint3D in [joint_fork_l, joint_fork_r]:
		joint.set_param_x(
			Generic6DOFJoint3D.PARAM_LINEAR_MOTOR_FORCE_LIMIT,
			fork_motor_max_force
		)
		joint.set_param_x(
			Generic6DOFJoint3D.PARAM_LINEAR_MOTOR_TARGET_VELOCITY,
			0.0
		)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"reset_truck"):
		reset_truck()


func _physics_process(delta: float) -> void:
	_process_accellerations(delta)
	_process_steering(delta)
	_process_driving(delta)
	_process_mast(delta)
	_process_lift(delta)
	_process_fork(delta)


func _process_accellerations(delta: float) -> void:
	if steer_input:
		steering_acc = min(steering_acc + 5.0 * delta, 1.0)
	else:
		steering_acc = 0.0
	
	if _tilt_input:
		_tilt_acc = min(_tilt_acc + delta, abs(_tilt_input))
	else:
		_tilt_acc = 0.0
	
	if _lift_input:
		_lift_acc = min(_lift_acc + delta, abs(_lift_input))
	else:
		_lift_acc = 0.0
	
	if _shift_input:
		_shift_acc = min(_shift_acc + delta * 0.7, abs(_shift_input))
	else:
		_shift_acc = 0.0


func _process_steering(delta: float) -> void:
	# steering
	target_steering += steer_input * steering_speed * steering_acc * delta
	vehicle_body.steering = lerpf(
		vehicle_body.steering,
		target_steering,
		15.0 * delta
	)
	
	# snap steering
	if Input.is_action_just_released(&"steer_left") or \
			Input.is_action_just_released(&"steer_right"):
		if not _drive_input or settings.snap_while_drive:
			_snap_target_steering()


func _process_driving(delta: float) -> void:
	# throttle direction
	if Input.is_action_just_released(&"back") or \
			Input.is_action_just_released(&"forward"):
		_wrapped_steering = abs(wrapf(vehicle_body.steering, -PI, PI))
		_throttle_dir = -1 if _wrapped_steering > PI/2 else 1
	
	# throttle input
	if _drive_input:
		_target_throttle = lerp(
			_target_throttle,
			throttle_max_power * _drive_input * _throttle_dir,
			5.0 * delta)
		vehicle_body.brake = 0.0
	
	else:
		_target_throttle = 0.0
		vehicle_body.engine_force = 0.0
		if current_speed > 1.0:
			vehicle_body.brake = brake_max_force
		elif current_speed > 0.05:
			vehicle_body.brake = remap(
				current_speed,
				0.0,
				1.0,
				brake_min_force,
				brake_max_force
			)
		else:
			vehicle_body.brake = brake_max_force
	
	vehicle_body.engine_force = lerpf(
		vehicle_body.engine_force,
		_target_throttle * settings.speed_mult,
		5.0 * delta
	)


func _process_mast(delta: float) -> void:
	_target_tilt += _tilt_input * mast_tilt_speed * _tilt_acc * delta
	_target_tilt = clampf(
		_target_tilt,
		deg_to_rad(mast_tilt_min),
		deg_to_rad(mast_tilt_max)
	)
	
	var tilt_error: float = _target_tilt - mast_tilt
	var tilt_velocity := clampf(
		tilt_error * 5.0,
		-mast_tilt_speed,
		mast_tilt_speed
	)

	joint_mast.set_param_x(
		Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY,
		tilt_velocity
	)


func _process_lift(delta: float) -> void:
	_target_lift += _lift_input * lift_max_speed * _lift_acc * delta
	_target_lift = clampf(_target_lift, lift_min_height, lift_max_height)
	
	var lift_error: float = _target_lift - lift_height
	var lift_velocity := clampf(
		lift_error * 5.0,
		-lift_max_speed,
		lift_max_speed
	)
	
	joint_carriage.set_param_x(
		Generic6DOFJoint3D.PARAM_LINEAR_MOTOR_TARGET_VELOCITY,
		lift_velocity
	)


func _process_fork(delta: float) -> void:
	var desired_shift: float = _target_shift
	var desired_width: float = _target_width

	# Shift both forks together.
	if _shift_input:
		var shift_delta: float = _shift_input * fork_shift_speed * _shift_acc * delta
		var available_shift: float = (fork_max_width - desired_width) * 0.5
		desired_shift = clamp(
			desired_shift + shift_delta,
			-available_shift,
			available_shift
		)
		_target_shift = desired_shift

	# Widen / shrink around the current pair center.
	if _widen_input:
		var width_delta: float = _widen_input * fork_widen_speed * delta
		var available_width: float = fork_max_width - absf(desired_shift) * 2.0
		desired_width = clamp(
			desired_width + width_delta,
			fork_min_width,
			available_width
		)
		_target_width = desired_width
	
	var desired_l: float = desired_shift - desired_width * 0.5
	var desired_r: float = desired_shift + desired_width * 0.5
	var velocity_l := (desired_l - fork_l_position) / delta
	var velocity_r := (desired_r - fork_r_position) / delta
	
	joint_fork_l.set_param_x(
		Generic6DOFJoint3D.PARAM_LINEAR_MOTOR_TARGET_VELOCITY,
		velocity_l
	)
	joint_fork_r.set_param_x(
		Generic6DOFJoint3D.PARAM_LINEAR_MOTOR_TARGET_VELOCITY,
		velocity_r
	)


func _process(delta: float) -> void:
	_process_audio(delta)
	_process_mast_audio()
	_process_mast_extension()
	_process_thrust_wheel_visuals(delta)
	
	var info: String = "wrapped_steering: %.3f" % [rad_to_deg(_wrapped_steering)]
	info += "\n Forward Verse: %d" % _throttle_dir
	text_nfo.text = info


func _process_audio(delta: float) -> void:
	var is_accelerating: bool = _drive_input != 0.0
	var moving_speed: float = vehicle_body.linear_velocity.length()
	
	if is_accelerating and not sfx_engine_loop.playing:
		_engine_audio_volume = 0.25
		sfx_engine_loop.volume_db = linear_to_db(_engine_audio_volume)
		sfx_engine_loop.play()

	# Fade volume toward desired level
	var target_volume := 1.0 if is_accelerating else 0.0
	_engine_audio_volume = move_toward(_engine_audio_volume, target_volume, 0.5 * delta)
	
	if sfx_engine_loop.playing:
		sfx_engine_loop.volume_db = linear_to_db(maxf(_engine_audio_volume, 0.0001))
		sfx_engine_loop.pitch_scale = remap(moving_speed, 0.1, 6.0, 0.6, 1.0)
		sfx_engine_loop.pitch_scale = min(sfx_engine_loop.pitch_scale, 1.0)
	
	if not is_accelerating \
			and moving_speed < 0.1 \
			and sfx_engine_loop.playing:
		sfx_engine_loop.stop()
		
		
func _process_mast_audio() -> void:
#Mast
	var is_lifting: bool = abs(_lift_input) > 0.05
	if is_lifting:
		if not sfx_mast_loop.playing:
			sfx_mast_loop.play()
	else:
		if sfx_mast_loop.playing:
			sfx_mast_loop.stop()
	
#Forks
	var is_moving_forks: bool = abs(_shift_input) > 0.05 or abs(_widen_input) > 0.05
	if is_moving_forks:
		if not sfx_mast_clunk.playing:
			sfx_mast_clunk.play()
	else:
		if sfx_mast_clunk.playing:
			sfx_mast_clunk.stop()

#var _was_accelerating: bool = false
#func _process_audio(_delta: float) -> void:
	#var is_accelerating: bool = abs(_drive_input) > 0.01
	#var moving_speed: float = vehicle_body.linear_velocity.length()
	#
	##Release
	#if _was_accelerating and not is_accelerating and moving_speed > 0.1:
			#audio_accel.stop()
			#sfx_engine_loop.stop()
			#audio_decel.volume_db = 0.0 # dirty hack to make sure volume is max
			#
			#audio_decel.play()
	#
	##Accelerate
	#if is_accelerating and not _was_accelerating:
			#audio_decel.stop()
			#sfx_engine_loop.stop()
			#audio_accel.volume_db = 0.0# dirty hack to make sure volume is max
			#
			#audio_accel.play()
## 		Crossfade ( I cannot seem to get this crossfading working between accelerate - loop - decelerate, 
## 		try cutting off the accelerate off at the end and decelerate so they hit dont fade out)
	#
	#
	#if audio_accel.playing and audio_accel.stream:
			#var stream_length := audio_accel.stream.get_length()
			#var current_pos := audio_accel.get_playback_position()
			#
			## Start blending 0.2 seconds before the acceleration clip ends
			#var blend_duration: float = 0.2
			#if stream_length > blend_duration and current_pos >= (stream_length - blend_duration):
				#if not sfx_engine_loop.playing:
					#sfx_engine_loop.volume_db = 0.0
					#sfx_engine_loop.play()
				#
				## Crossfade 
				#var progress := (current_pos - (stream_length - blend_duration)) / blend_duration
				#audio_accel.volume_db = linear_to_db(clamp(1.0 - progress, 0.0, 1.0))
				#sfx_engine_loop.volume_db = linear_to_db(clamp(progress, 0.0, 1.0))
#
	#elif is_accelerating and not audio_accel.playing and not sfx_engine_loop.playing:
		#sfx_engine_loop.volume_db = 0.0
		#sfx_engine_loop.play()
		#
	## stop sounds when stopped
	#if moving_speed < 0.1 and not is_accelerating:
		#audio_accel.stop()
		#sfx_engine_loop.stop()
		#audio_decel.stop()
	#
	## Pitch mod (working)
	#if sfx_engine_loop.playing:
		#sfx_engine_loop.pitch_scale = clamp(0.8 + (moving_speed * 0.05), 0.8, 1.2)
	#
	#_was_accelerating = is_accelerating


func _process_mast_extension() -> void:
	const START_EXTENSION: float = 2.0 # m
	const MAX_EXTENSION_1: float = 1.6 # m
	var extension_offset1: float = maxf(0.0, lift_height - START_EXTENSION)
	var extension_offset2: float = minf(extension_offset1, MAX_EXTENSION_1)
	mast_1.position.y = extension_offset1
	mast_2.position.y = extension_offset2
	mast_coll_extension.position.y = _mast_coll_extension_start_y_pos + extension_offset1


func _process_thrust_wheel_visuals(delta: float) -> void:
	# update visual steering
	rear_wheel_visual_pivot.rotation.y = wheel_thrust.rotation.y
	
	# update visual wheel rotation
	var forward_velocity: float = vehicle_body.global_transform.basis.z.dot(
		vehicle_body.linear_velocity
	)
	var wheel_rotation_speed := forward_velocity / wheel_thrust.wheel_radius
	thrust_wheel.rotate_object_local(Vector3.RIGHT, wheel_rotation_speed * delta)
	
	# alternate wheel rotation implementation
	#var wheel_rps: float = wheel_thrust.get_rpm() / 60.0
	#thrust_wheel.rotate_object_local(Vector3.RIGHT, TAU * wheel_rps * delta)
	
	# update suspension position
	rear_wheel_visual_pivot.position.y = wheel_thrust.position.y


func _process_cam_focus_markers() -> void:
	fork_focus.position.x = fork_shift


func reset_truck() -> void:
	var old_vehicle_transform := vehicle_body.global_transform
	
	var forward: Vector3 = -old_vehicle_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	
	# Construct an upright basis preserving the truck's heading
	var right: Vector3 = forward.cross(Vector3.UP).normalized()
	var target_basis := Basis(
		right,
		Vector3.UP,
		-forward
	).orthonormalized()

	# Preserve X/Z position, but raise it slightly above the floor
	var target_position := old_vehicle_transform.origin
	target_position.y = reset_raise

	var target_vehicle_transform := Transform3D(
		target_basis,
		target_position
	)

	# Transform that takes the current truck pose into the reset pose.
	var reset_transform := (
		target_vehicle_transform
		* old_vehicle_transform.affine_inverse()
	)

	var bodies: Array[RigidBody3D] = [
		vehicle_body,
		mast_body,
		carriage_body,
		fork_l_body,
		fork_r_body,
	]

	for body: RigidBody3D in bodies:
		var new_transform := reset_transform * body.global_transform

		PhysicsServer3D.body_set_state(
			body.get_rid(),
			PhysicsServer3D.BODY_STATE_TRANSFORM,
			new_transform
		)

		PhysicsServer3D.body_set_state(
			body.get_rid(),
			PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY,
			Vector3.ZERO
		)

		PhysicsServer3D.body_set_state(
			body.get_rid(),
			PhysicsServer3D.BODY_STATE_ANGULAR_VELOCITY,
			Vector3.ZERO
		)

		PhysicsServer3D.body_set_state(
			body.get_rid(),
			PhysicsServer3D.BODY_STATE_SLEEPING,
			false
		)

	# Stop propulsion.
	_target_throttle = 0.0
	vehicle_body.engine_force = 0.0

	# Stop/hold all actuators.
	joint_carriage.set_param_x(
		Generic6DOFJoint3D.PARAM_LINEAR_MOTOR_TARGET_VELOCITY,
		0.0
	)

	joint_mast.set_param_x(
		Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY,
		0.0
	)

	joint_fork_l.set_param_x(
		Generic6DOFJoint3D.PARAM_LINEAR_MOTOR_TARGET_VELOCITY,
		0.0
	)

	joint_fork_r.set_param_x(
		Generic6DOFJoint3D.PARAM_LINEAR_MOTOR_TARGET_VELOCITY,
		0.0
	)


func _snap_target_steering() -> void:
	if settings.steering_snap == GameSettings.SteeringSnap.NONE:
		return
	var cardinal_snap: float = settings.steering_snap_cardinal_rad
	var increment_snap: float = settings.steering_snap_increment_rad
	
	match settings.steering_snap:
		GameSettings.SteeringSnap.FORWARD:
			var steer_diff: float = absf(wrapf(target_steering, -PI_half, PI_half))
			if steer_diff < cardinal_snap:
				target_steering = snappedf(target_steering, PI)
		GameSettings.SteeringSnap.CARDINAL:
			var steer_diff: float = absf(wrapf(target_steering, -PI_quarter, PI_quarter))
			if steer_diff < cardinal_snap:
				target_steering = snappedf(target_steering, PI_half)
		GameSettings.SteeringSnap.INCREMENTS:
			target_steering = snappedf(target_steering, increment_snap)


func get_lift_height() -> float:
	var carriage_in_mast: Vector3 = mast_body.to_local(carriage_body.global_position)
	return carriage_in_mast.y


func get_mast_tilt_rad() -> float:
	var relative_basis: Basis = (
		vehicle_body.global_transform.basis.inverse()
		* mast_body.global_transform.basis
	)
	return relative_basis.get_euler().x
func get_mast_tilt_degree() -> float:
	return rad_to_deg(get_mast_tilt_rad())
