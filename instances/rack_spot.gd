class_name RackLocation
extends Area3D


enum State{
	NONE,
	FREE,
	WRONG,
	GOOD_NOT_ALIGNED,
	GOOD_ALIGNED,
}

@export var must_be_freed: bool

@onready var mesh: MeshInstance3D = $mesh

var state: State = State.FREE: set = set_state
var _tracked_pallet: Pallet
var _tracked_dist: float:
	get:
		if not _tracked_pallet:
			return 0.0
		var tr_pos2d := Vector2(
			_tracked_pallet.global_position.x,
			_tracked_pallet.global_position.z
		)
		var pos2d := Vector2(global_position.x, global_position.z)
		return tr_pos2d.distance_squared_to(pos2d)
var _tracked_rot: float:
	get:
		if not _tracked_pallet:
			return 0.0
		return wrapf(_tracked_pallet.global_rotation.y - global_rotation.y, -PI/2, PI/2)
var _tolerance_dist: float:
	get: return Mng.settings.pallet_tolerance_dist
var _tolerance_rot: float:
	get: return Mng.settings.pallet_tolerance_rot


func _ready() -> void:
	if not Engine.is_editor_hint():
		_check_overlapping_pallets()


func set_state(value: State) -> void:
	state = value
	if not is_node_ready(): await ready
	if must_be_freed:
		match state:
			State.FREE: mesh.material_override = preload("uid://drhlbi35wusht")
			_: mesh.material_override = preload("uid://dc3vrhfiklpkw")
	else:
		match state:
			State.FREE: mesh.material_override = preload("uid://c7qynw0inx2f4")
			State.WRONG: mesh.material_override = preload("uid://dc3vrhfiklpkw")
			State.GOOD_NOT_ALIGNED: mesh.material_override = preload("uid://ba32lims6w1ei")
			State.GOOD_ALIGNED: mesh.material_override = preload("uid://drhlbi35wusht")


func _process(_delta: float) -> void:
	if state in [State.FREE, State.WRONG]:
		return
	if not _tracked_pallet:
		return
	if _tracked_pallet.sleeping:
		return
	
	if not is_pallet_aligned() and state == State.GOOD_ALIGNED:
		state = State.GOOD_NOT_ALIGNED
	elif is_pallet_aligned() and state == State.GOOD_NOT_ALIGNED:
		state = State.GOOD_ALIGNED


func _check_overlapping_pallets() -> void:
	var bodies = get_overlapping_bodies()
	if bodies.is_empty():
		state = State.FREE
		_tracked_pallet = null
		return
	
	var min_dist: float = INF
	for pallet: Pallet in bodies:
		var dist: float = pallet.global_position.distance_squared_to(global_position)
		if dist < min_dist:
			min_dist = dist
			_tracked_pallet = pallet
	
	if _tracked_pallet.to_deliver:
		state = State.GOOD_NOT_ALIGNED
	else:
		state = State.WRONG


func is_pallet_aligned() -> bool:
	if not _tracked_pallet:
		return false
	if abs(_tracked_dist) > _tolerance_dist:
		return false
	if abs(_tracked_dist) > _tolerance_dist:
		return false
	if abs(_tracked_rot) > _tolerance_rot:
		return false
	return true


func _on_body_entered(_pallet: Pallet) -> void: _check_overlapping_pallets()
func _on_body_exited(_pallet: Pallet) -> void: _check_overlapping_pallets()
