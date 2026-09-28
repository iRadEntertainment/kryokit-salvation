# Singleton Audio Manager
extends Node

@onready var mus_title: AudioStreamPlayer = $mus_title

@onready var ui_btn_click: AudioStreamPlayer = $ui_btn_click
@onready var ui_btn_hover: AudioStreamPlayer = $ui_btn_hover


func _ready() -> void:
	get_tree().scene_changed.connect(_on_scene_changed)
	_get_buttons.call_deferred(get_tree().current_scene)


func _on_scene_changed() -> void:
	_get_buttons(get_tree().current_scene)


func _get_buttons(node: Node) -> void:
	if node is BaseButton or node is Slider:
		_register_ui_sfx_control(node)
	for child in node.get_children():
		_get_buttons(child)


func _register_ui_sfx_control(ctrl: Control) -> void:
	if ctrl is BaseButton:
		ctrl.mouse_entered.connect(_on_btn_hovered.bind(ctrl))
		ctrl.pressed.connect(play_btn_pressed)
	elif ctrl is Slider:
		ctrl.value_changed.connect(play_slider_changed.unbind(1))


func _on_btn_hovered(btn: BaseButton) -> void:
	if not btn.disabled:
		play_btn_hover()


func play_mus_title() -> void: mus_title.play()
func play_btn_pressed() -> void: ui_btn_click.play()
func play_btn_hover() -> void: ui_btn_hover.play()
func play_slider_changed() -> void: ui_btn_hover.play()
