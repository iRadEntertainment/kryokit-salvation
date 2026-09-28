class_name GameSettings
extends Node

enum SteeringSnap {
	NONE,
	FORWARD,
	CARDINAL,
	INCREMENTS
}
enum SpeedMode {
	VERY_SLOW,
	SLOW,
	MEDIUM,
	FAST,
	SUPER_FAST,
}
const SPEED_MULT = {
	SpeedMode.VERY_SLOW: [0.50, "very slow"],
	SpeedMode.SLOW: [0.75, "slow"],
	SpeedMode.MEDIUM: [1.00, "medium"],
	SpeedMode.FAST: [1.25, "fast"],
	SpeedMode.SUPER_FAST: [1.50, "super-fast"],
}

# Global
var file_path: String

# Audio
var bus_volumes_linear: Array

# Game
var speed_mode: SpeedMode
var steering_snap: SteeringSnap
var steering_snap_cardinal_deg: float = 5.0:
	set(value):
		steering_snap_cardinal_deg = value
		steering_snap_cardinal_rad = deg_to_rad(value)
var steering_snap_increment_deg: float = 5.0:
	set(value):
		steering_snap_increment_deg = value
		steering_snap_increment_rad = deg_to_rad(value)
var snap_while_drive: bool

# getters
var speed_mult: float:
	get: return SPEED_MULT[speed_mode][0]
var speed_mult_label: String:
	get: return SPEED_MULT[speed_mode][1].capitalize()
var steering_snap_cardinal_rad: float #set by the increment in degrees
var steering_snap_increment_rad: float #set by the increment in degrees


func save() -> Error:
	var config := ConfigFile.new()
	# Global
	config.set_value("Game", "file_path", file_path)
	# Audio
	config.set_value("Audio", "bus_volumes_linear", _get_audio_bus_linear_volumes())
	# Game
	config.set_value("Game", "speed_mode", speed_mode)
	config.set_value("Game", "steering_snap", steering_snap)
	config.set_value("Game", "steering_snap_cardinal_deg", steering_snap_cardinal_deg)
	config.set_value("Game", "steering_snap_increment_deg", steering_snap_increment_deg)
	config.set_value("Game", "snap_while_drive", snap_while_drive)
	
	var err: Error = config.save(file_path)
	if not err:
		print("GameSettings saved!")
	else:
		print("GameSettings save error: code(%s)" % err)
	return err


func apply_audio_bus_volumes() -> void:
	for bus_idx: int in AudioServer.bus_count:
		if bus_idx >= bus_volumes_linear.size():
			break
		var value: float = bus_volumes_linear[bus_idx]
		AudioServer.set_bus_volume_linear(bus_idx, value)


func _get_audio_bus_linear_volumes() -> Array:
	var volumes: Array = []
	for bus_idx: int in AudioServer.bus_count:
		volumes.append(AudioServer.get_bus_volume_linear(bus_idx))
	return volumes


static func from_config_file(settings_file_path: String) -> GameSettings:
	var new := GameSettings.new()
	new.file_path = settings_file_path
	
	if not FileAccess.file_exists(settings_file_path):
		push_warning("Cannot find %s. Returning new GameSettings" % settings_file_path)
		return new
	
	var config := ConfigFile.new()
	var err: Error = config.load(settings_file_path)
	if err:
		push_warning("Cannot load %s. Returning new GameSettings" % settings_file_path)
		return new
	
	new.bus_volumes_linear = config.get_value("Audio", "bus_volumes_linear", [])
	new.speed_mode = config.get_value("Game", "speed_mode", SpeedMode.MEDIUM)
	new.steering_snap = config.get_value("Game", "steering_snap", SteeringSnap.CARDINAL)
	new.steering_snap_cardinal_deg = config.get_value("Game", "steering_snap_cardinal_deg", 5.0)
	new.steering_snap_increment_deg = config.get_value("Game", "steering_snap_increment_deg", 5.0)
	new.snap_while_drive = config.get_value("Game", "snap_while_drive", false)
	
	return new
