extends PanelContainer


@onready var sl_speed: HSlider = %sl_speed
@onready var lb_speed: Label = %lb_speed

@onready var opt_snap_type: OptionButton = %opt_snap_type

@onready var hb_sub_snap: HBoxContainer = %hb_sub_snap
@onready var hb_cardinal: HBoxContainer = %hb_cardinal
@onready var sl_snap_card: HSlider = %sl_snap_card
@onready var lb_snap_card: Label = %lb_snap_card
@onready var hb_increments: HBoxContainer = %hb_increments
@onready var sl_snap_incr: HSlider = %sl_snap_incr
@onready var lb_snap_incr: Label = %lb_snap_incr
@onready var ck_snap_while_drive: CheckButton = %ck_snap_while_drive


var settings: GameSettings:
	get: return Mng.settings

func _ready() -> void:
	sl_speed.max_value = GameSettings.SpeedMode.values().size() -1
	sl_speed.tick_count = GameSettings.SpeedMode.values().size()
	sl_speed.value = settings.speed_mode as int
	lb_speed.text = settings.speed_mult_label
	
	opt_snap_type.select(settings.steering_snap as int)
	sl_snap_card.value = settings.steering_snap_cardinal_deg
	sl_snap_incr.value = settings.steering_snap_increment_deg
	lb_snap_card.text = "%.1f°" % settings.steering_snap_cardinal_deg
	lb_snap_incr.text = "%.1f°" % settings.steering_snap_increment_deg
	ck_snap_while_drive.button_pressed = settings.snap_while_drive
	_update_snap_subpanel()
	
	_connect_signals()


func _connect_signals() -> void:
	sl_speed.value_changed.connect(_on_sl_speed_value_changed)
	opt_snap_type.item_selected.connect(_on_opt_snap_type_item_selected)
	sl_snap_card.value_changed.connect(_on_sl_snap_card_value_changed)
	sl_snap_incr.value_changed.connect(_on_sl_snap_incr_value_changed)
	ck_snap_while_drive.toggled.connect(_on_ck_snap_while_drive_toggled)


func _update_snap_subpanel() -> void:
	hb_sub_snap.visible = settings.steering_snap != GameSettings.SteeringSnap.NONE
	hb_cardinal.visible = settings.steering_snap in [GameSettings.SteeringSnap.FORWARD, GameSettings.SteeringSnap.CARDINAL]
	hb_increments.visible = settings.steering_snap == GameSettings.SteeringSnap.INCREMENTS


func _on_sl_speed_value_changed(value: float) -> void:
	settings.speed_mode = int(value) as GameSettings.SpeedMode
	lb_speed.text = settings.speed_mult_label


func _on_opt_snap_type_item_selected(idx: int) -> void:
	settings.steering_snap = idx as GameSettings.SteeringSnap
	_update_snap_subpanel()


func _on_sl_snap_card_value_changed(value: float) -> void:
	settings.steering_snap_cardinal_deg = value
	lb_snap_card.text = "%.1f°" % settings.steering_snap_cardinal_deg


func _on_sl_snap_incr_value_changed(value: float) -> void:
	settings.steering_snap_increment_deg = value
	lb_snap_incr.text = "%.1f°" % settings.steering_snap_increment_deg


func _on_ck_snap_while_drive_toggled(toggled: bool) -> void:
	settings.snap_while_drive = toggled
