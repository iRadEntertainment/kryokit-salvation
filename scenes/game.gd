class_name Game
extends Node3D


@export var is_tutorial: bool = false


func _init() -> void:
	Mng.game = self


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Register Goods-In markers as valid pickups
	MissionManager.register_pickup_target(%in_marker_1)
	MissionManager.register_pickup_target(%in_marker_2)
	
	# Register Goods-Out markers as valid drop-offs
	MissionManager.register_dropoff_target(%out_marker_1)
	MissionManager.register_dropoff_target(%out_marker_2)
	
	# Automatically find and register all rack locations (`loc_1`, `loc_2`, etc.)
	for node in get_tree().get_nodes_in_group("racks"):
		for child in node.get_children():
			if child is Marker3D and child.name.begins_with("loc_"):
				# Racks can be both pickup sources and drop-off destinations
				MissionManager.register_pickup_target(child)
				MissionManager.register_dropoff_target(child)
				
