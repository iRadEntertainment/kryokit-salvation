class_name Pallet extends RigidBody3D


const HIT_SFX_UIDS := [
	"uid://cp181cg51n8ml",
	"uid://cpr4g3m35lml7",
	"uid://bwcvu8wg5jpkc",
	"uid://dujm7gvsbgulx",
	"uid://cj6jjq68jv57n",
	"uid://rt64p4elycp3",
	"uid://vq62oll3syth",
]

@export var sfx_min_linear_speed: float = 1.0
@export var sfx_min_angular_speed: float = 0.8

@onready var sfx_collision: AudioStreamPlayer3D = $sfx_collision



func _on_body_entered(_body: Node) -> void:
	var linear_speed: float = linear_velocity.length()
	var angular_speed: float = angular_velocity.length()
	
	if linear_speed >= sfx_min_linear_speed or \
			angular_speed >= sfx_min_angular_speed:
		play_impact_sound()


func play_impact_sound() -> void:
	sfx_collision.stop()
	sfx_collision.stream = load(HIT_SFX_UIDS.pick_random())
	sfx_collision.play()
