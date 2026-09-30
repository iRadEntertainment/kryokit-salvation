class_name GUI
extends CanvasLayer

@onready var disclaimer: PanelContainer = $disclaimer

func _init() -> void:
	Mng.gui = self


func _ready() -> void:
	disclaimer.show()


func _input(event: InputEvent) -> void:
	if not disclaimer.visible:
		return
	if event is InputEventKey:
		disclaimer.hide()
