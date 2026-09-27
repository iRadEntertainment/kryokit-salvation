class_name HUD
extends Control

@onready var throttle_bar: ProgressBar = %throttle_bar
@onready var drive_wheel: TextureRect = %drive_wheel
@onready var wheel_indicator: TextureRect = %wheel_indicator

@onready var truck: TextureRect = %truck
@onready var fork_l: TextureRect = %fork_l
@onready var fork_r: TextureRect = %fork_r
@onready var thrust_wheel: TextureRect = %thrust_wheel

var forklift: Forklift:
	get: return Mng.forklift
var engine_force: float:
	get: return forklift.vehicle_body.engine_force
var steer_input: float:
	get: return forklift.steer_input
var steering_speed: float:
	get: return forklift.steering_speed
var steering_acc: float:
	get: return forklift.steering_acc
var target_steering: float:
	get: return forklift.target_steering
var fork_l_pos_x: float:
	get: return forklift.fork_l_position
var fork_r_pos_x: float:
	get: return forklift.fork_r_position


var _truck_ico_center_x: float

func _init() -> void:
	Mng.hud = self


func _ready() -> void:
	_truck_ico_center_x = truck.size.x / 2


func _process(delta: float) -> void:
	if not forklift:
		return
	
	throttle_bar.value = absf(engine_force) / forklift.throttle_max_power
	drive_wheel.offset_transform_rotation -= steer_input * steering_speed \
		* steering_acc * delta * 8.0
	wheel_indicator.offset_transform_rotation = -wrapf(
		target_steering,
		-PI/2, PI/2
	)
	thrust_wheel.offset_transform_rotation = -target_steering
	fork_l.position.x = _truck_ico_center_x - _truck_ico_center_x * fork_l_pos_x * 1.95 - 3.0
	fork_r.position.x = _truck_ico_center_x - _truck_ico_center_x * fork_r_pos_x * 1.95 - 3.0
