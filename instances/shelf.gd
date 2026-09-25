@tool
class_name Shelf
extends Node3D

const POST_GLB := preload("uid://bgql3g46eolgy")
const BEAM_GLB := preload("uid://bptwc3hmor044")

@export_tool_button("Generate")
@warning_ignore("unused_private_class_variable")
var _btn_generate: Callable = _generate_in_engine

@export var post_dimensions := Vector3(0.20, 6.40, 0.12)
@export var beam_dimensions := Vector3(3.00, 0.15, 0.08)
@export var bay_depth_post_to_post: float = 1.1
@export var bays_data: Array[Array] = [
	[1.6, 3.2, 4.8],
	[1.6, 3.2, 4.8],
	[1.6, 3.2, 4.8],
	[1.6, 3.2, 4.8],
]

@onready var meshes: Node3D = %meshes
@onready var static_body: StaticBody3D = %static_body


var _collision_shape_post: BoxShape3D
var _collision_shape_beam: BoxShape3D

var _bay_count: int:
	get: return bays_data.size()
var _posts_spacing_center_to_center: float:
	get: return post_dimensions.x + beam_dimensions.x


func _ready() -> void:
	_generate_in_engine()


func _generate_in_engine() -> void:
	_clear()
	_setup_shapes()
	_generate_metal_structure()


func _setup_shapes() -> void:
	_collision_shape_post = BoxShape3D.new()
	_collision_shape_post.size = post_dimensions
	_collision_shape_beam = BoxShape3D.new()
	_collision_shape_beam.size = beam_dimensions


func _clear() -> void:
	for child in static_body.get_children() + meshes.get_children():
		child.free()


func _generate_metal_structure() -> void:
	for bay_idx: int in _bay_count + 1:
		for z_pos: float in [0.0, bay_depth_post_to_post]:
			var orientation: float = 0.0 if z_pos != 0.0 else PI
			
			# add posts
			var post_pos := Vector3(
				bay_idx * _posts_spacing_center_to_center,
				0.0,
				z_pos
			)
			_place_post(post_pos, orientation)
			
			# add beams
			if bay_idx < _bay_count:
				for height: float in bays_data[bay_idx]:
					var beam_pos: Vector3 = post_pos
					beam_pos.x += _posts_spacing_center_to_center * 0.5
					beam_pos.y = height
					_place_beam(beam_pos, orientation)


func _place_post(center_pos: Vector3, post_rotation: float) -> void:
	# mesh
	var post_mesh_instance: Node3D = POST_GLB.instantiate()
	post_mesh_instance.position = center_pos
	post_mesh_instance.rotation.y = post_rotation
	meshes.add_child(post_mesh_instance)
	
	# collision
	var coll := CollisionShape3D.new()
	coll.shape = _collision_shape_post
	coll.position = center_pos
	coll.position.y += _collision_shape_post.size.y * 0.5
	coll.rotation.y = post_rotation
	static_body.add_child(coll)


func _place_beam(center_top_pos: Vector3, beam_rotation: float) -> void:
	# mesh
	var beam_mesh_instance: Node3D = BEAM_GLB.instantiate()
	beam_mesh_instance.position = center_top_pos
	beam_mesh_instance.rotation.y = beam_rotation
	meshes.add_child(beam_mesh_instance)
	
	# collision
	var coll := CollisionShape3D.new()
	coll.shape = _collision_shape_beam
	coll.position = center_top_pos
	coll.position.y -= _collision_shape_beam.size.y * 0.5
	coll.rotation.y = beam_rotation
	static_body.add_child(coll)
