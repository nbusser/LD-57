class_name HUD

extends Control

var level_name:
	set = set_level_name

var level_number:
	set = set_level_number

@onready var level_number_label: Label = $VBoxContainer/VBoxContainer/LevelNumber/LevelNumberValue
@onready var level_name_label: Label = $VBoxContainer/CenterContainer/LevelNameValue
@onready var fadein_pane: ColorRect = $FadeinPane


func set_level_name(value: String) -> void:
	level_name_label.text = value


func set_level_number(value: int) -> void:
	level_number_label.text = str(value)


func init(level_state: LevelState) -> void:
	level_name = level_state.level_data.name
	level_number = level_state.level_number


func _ready() -> void:
	# Fadein animation
	fadein_pane.visible = 1
	create_tween().tween_property(fadein_pane, "modulate", Color.TRANSPARENT, 0.7)
