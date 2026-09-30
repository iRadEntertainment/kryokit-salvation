extends Node

const PALLET_SCENE_PATH := "res://instances/pallet.tscn"

#list of loads
const LOAD_SCENES: Array[String] = [
	"res://instances/cement_bag.tscn",
	#"res://instances/load_blackwrap.tscn",
]

var success_tolerance: float = 0.5 # meters between pallet and target 

var pickup_markers: Array[Marker3D] = []
var dropoff_markers: Array[Marker3D] = []

# Stores serializable data: { "NodePathString": { "pallet": String, "load": String } } # this is incase you want to add save state later on we can write the string to JSON
var marker_contents: Dictionary = {}

var current_target_marker: Marker3D = null
var active_pallet: Node3D = null
var active_load: Node3D = null
var current_load_path: String = ""
var mission_active: bool = false
var current_pickup_marker: Marker3D = null

var pickup_indicator: Node3D = null
var dropoff_indicator: Node3D = null


func _ready() -> void:
	await get_tree().process_frame
	gather_markers()
	start_new_task()


func register_pickup_target(marker: Marker3D) -> void:
	if not pickup_markers.has(marker):
		pickup_markers.append(marker)


func register_dropoff_target(marker: Marker3D) -> void:
	if not dropoff_markers.has(marker):
		dropoff_markers.append(marker)


func gather_markers() -> void:
	pickup_markers.clear()
	dropoff_markers.clear()
	marker_contents.clear()
	
	var current_scene := get_tree().current_scene
	if current_scene:
		if current_scene.has_node("locations/in_marker_1"): pickup_markers.append(current_scene.get_node("locations/in_marker_1"))
		if current_scene.has_node("locations/in_marker_2"): pickup_markers.append(current_scene.get_node("locations/in_marker_2"))
		if current_scene.has_node("locations/out_marker_1"): dropoff_markers.append(current_scene.get_node("locations/out_marker_1"))
		if current_scene.has_node("locations/out_marker_2"): dropoff_markers.append(current_scene.get_node("locations/out_marker_2"))
	
	var racks := get_tree().get_nodes_in_group("racks")
	print("DEBUG: Found ", racks.size(), " nodes in group 'racks'.")
	
	for node: Node in racks:
		for child: Node in node.get_children():
			if child is Marker3D and child.name.begins_with("loc_"):
				pickup_markers.append(child)
				dropoff_markers.append(child)
				print("  -> Registered rack location: ", child.name)


func start_new_task() -> void:
	if pickup_markers.is_empty() or dropoff_markers.is_empty():
		print("MissionManager: Not enough markers found to create a task!")
		return
	
	if pickup_indicator: pickup_indicator.queue_free()
	if dropoff_indicator: dropoff_indicator.queue_free()
	
	current_pickup_marker = pickup_markers.pick_random()
	
	var valid_dropoffs := dropoff_markers.filter(func(m): return m != current_pickup_marker)
	current_target_marker = valid_dropoffs.pick_random()
	
	var source_name := "%s/%s" % [current_pickup_marker.get_parent().name, current_pickup_marker.name]
	var target_name := "%s/%s" % [current_target_marker.get_parent().name, current_target_marker.name]
	
	print("MISSION: Move pallet from ", source_name, " to ", target_name)
	spawn_pallet_and_load(current_pickup_marker)
	
	pickup_indicator = _spawn_indicator(current_pickup_marker, Color(0, 1, 0, 0.4))
	dropoff_indicator = _spawn_indicator(current_target_marker, Color(1, 0, 0, 0.4))
	
	mission_active = true


func _spawn_indicator(marker: Marker3D, color: Color) -> Node3D:
	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(1.5, 5, 1.5)
	mesh_instance.mesh = box_mesh
	
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	mesh_instance.material_override = material
	
	get_tree().current_scene.add_child(mesh_instance)
	mesh_instance.global_transform = marker.global_transform
	return mesh_instance


func spawn_pallet_and_load(marker: Marker3D) -> void:
	var pallet_scene := load(PALLET_SCENE_PATH) as PackedScene
	if pallet_scene:
		active_pallet = pallet_scene.instantiate()
		get_tree().current_scene.add_child(active_pallet)
		active_pallet.global_transform = marker.global_transform
	
	current_load_path = LOAD_SCENES.pick_random()
	var load_scene := load(current_load_path) as PackedScene
	if load_scene:
		active_load = load_scene.instantiate()
		get_tree().current_scene.add_child(active_load)
		active_load.global_transform = marker.global_transform


func _physics_process(_delta: float) -> void:
	if not mission_active or not active_pallet or not current_target_marker:
		return
	
	var pallet_pos_marker: Marker3D = active_pallet.get_node_or_null("pallet_position")
	if not pallet_pos_marker:
		return
	
	var distance := pallet_pos_marker.global_position.distance_to(current_target_marker.global_position)
	
	if distance <= success_tolerance:
		print("success")
		mission_active = false
		
		if pickup_indicator: 
			pickup_indicator.queue_free()
			pickup_indicator = null
		if dropoff_indicator: 
			dropoff_indicator.queue_free()
			dropoff_indicator = null
		
		# Record serializable paths instead of raw memory node references
		var target_path_key := str(current_target_marker.get_path())
		marker_contents[target_path_key] = {
			"pallet": PALLET_SCENE_PATH,
			"load": current_load_path
		}
		
		# If the pickup came from a tracked location, clear it from record
		var pickup_path_key := str(current_pickup_marker.get_path())
		if marker_contents.has(pickup_path_key):
			marker_contents.erase(pickup_path_key)
			
		active_pallet = null
		active_load = null
		current_load_path = ""
		
		await get_tree().create_timer(2.0).timeout
		start_new_task()
