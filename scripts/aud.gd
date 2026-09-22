# Singleton Audio Manager
extends Node

@onready var mus_title: AudioStreamPlayer = %mus_title


func play_mus_title() -> void:
	mus_title.play()
