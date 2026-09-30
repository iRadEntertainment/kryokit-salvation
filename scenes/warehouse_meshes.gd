@tool
extends Node3D

@export_tool_button("Replace All")
var btn_all: Callable = _replace_all


@export var pck_wall: PackedScene
@export var pck_wall_corner: PackedScene
@export var pck_wall_refrigerated: PackedScene
@export var pck_truss: PackedScene
@export var pck_pillar: PackedScene
@export var pck_light: PackedScene
@export var pck_doorframe: PackedScene



func _replace_all() -> void:
	var dict: Dictionary = {
		"walls":
			[pck_wall, "wall"],
		"wall_corners":
			[pck_wall_corner, "wall_corner"],
		"refrigerated_walls":
			[pck_wall_refrigerated, "refrigerated_wall"],
		"trusses":
			[pck_truss, "truss"],
		"pillars":
			[pck_pillar, "pillar"],
		"lighting":
			[pck_light, "pillar"],
		"doorframes":
			[pck_doorframe, "doorframe"],
	}
	
	for group: String in dict.keys():
		
		var where: Node3D = get_node(group)
		var with: PackedScene = dict[group][0]
		var new_name: String = dict[group][1]
		if where and with and new_name:
			_replace_mesh(where, with, new_name)


func _replace_mesh(where: Node3D, with: PackedScene, new_name: String) -> void:
	for child: Node3D in where.get_children():
		var transf: Transform3D = child.transform
		child.free()
		var new: Node3D = with.instantiate()
		new.transform = transf
		new.name = new_name
		where.add_child(new, true)
		new.owner = owner
