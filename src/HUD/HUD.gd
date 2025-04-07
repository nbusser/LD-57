class_name HUD

extends Control

enum OverlayState {
	BLUE,
	RED,
	PINK,
	HIDDEN,
}

var level_name:
	set = set_level_name

var level_number:
	set = set_level_number

var current_state = OverlayState.HIDDEN

@onready var level_number_label: Label = $VBoxContainer/VBoxContainer/LevelNumber/LevelNumberValue
@onready var level_name_label: Label = $VBoxContainer/CenterContainer/LevelNameValue
@onready var fadein_pane: ColorRect = $FadeinPane
@onready var texture_rect: TextureRect = $BlueVignette


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
	texture_rect.modulate = Color.TRANSPARENT

	Globals.state_changed.connect(self.translate_global_states)


func translate_global_states(
	action_state: Globals.ActionState, enemy_state: Globals.BaseEnemyState
) -> void:
	# set_overlay_state(OverlayState.RED)
	match [action_state, enemy_state]:
		[_, Globals.BaseEnemyState.DISTRACTED]:
			set_overlay_state(OverlayState.BLUE)
		[Globals.ActionState.IDLE, _]:
			set_overlay_state(OverlayState.HIDDEN)
		[Globals.ActionState.ILLEGAL, Globals.BaseEnemyState.IDLE]:
			set_overlay_state(OverlayState.PINK)
		[Globals.ActionState.ILLEGAL, Globals.BaseEnemyState.ANGRY]:
			set_overlay_state(OverlayState.RED)


func set_overlay_state(state: OverlayState) -> void:
	if state == OverlayState.BLUE:
		create_tween().tween_property(texture_rect, "modulate", Color(0, 1, 1, 1), 0.7)
	elif state == OverlayState.RED:
		create_tween().tween_property(texture_rect, "modulate", Color(1, 0, 0, 1), 0.7)
	elif state == OverlayState.HIDDEN:
		create_tween().tween_property(texture_rect, "modulate", Color.TRANSPARENT, 0.7)
	elif state == OverlayState.PINK:
		create_tween().tween_property(texture_rect, "modulate", Color(1, 0, 1, 1), 0.7)
