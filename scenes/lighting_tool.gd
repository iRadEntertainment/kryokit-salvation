@tool
extends Node3D

@export_tool_button("Run")
var btn_run: Callable = _run


func _run() -> void:
	for child: Node3D in get_children():
		var transf: Transform3D = child.transform
		child.free()
		
		var new: Node3D = load("uid://v1421xnqe3qm").instantiate()
		new.transform = transf
		new.name = "light01"
		add_child(new)
		new.owner = owner
