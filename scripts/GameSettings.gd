class_name GameSettings
extends Node

# Global
var file_path: String

# Audio
var bus_volumes_linear: Array = [1.0, 1.0, 1.0, 1.0]

# Game



func save() -> Error:
	var config := ConfigFile.new()
	# Global
	config.set_value("Game", "file_path", file_path)
	# Audio
	config.set_value("Audio", "bus_volumes_linear", _get_audio_bus_linear_volumes())
	# Game
	
	var err: Error = config.save(file_path)
	if not err:
		print("GameSettings saved!")
	else:
		print(err)
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
	
	new.bus_volumes_linear = config.get_value("Audio", "bus_volumes_linear")
	
	return new
