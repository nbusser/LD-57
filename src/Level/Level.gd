class_name Level

extends Node

var level_state: LevelState

@onready var hud: HUD = $UI/HUD
@onready var timer: Timer = $Timer


func _ready():
	assert(level_state, "init must be called before creating Level scene")
	hud.init(level_state)

	timer.start(level_state.level_data.timer_duration)


func init(level_number_p: int, level_data_p: LevelData, nb_coins_p: int):
	level_state = LevelState.new(level_number_p, level_data_p, nb_coins_p)


func _on_Timer_timeout():
	pass
