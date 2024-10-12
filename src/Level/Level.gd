extends Node

signal end_of_level
signal game_over

var level_number
var nb_coins

@onready var hud = $UI/HUD
@onready var timer: Timer = $Timer

var level_data: LevelData


func _ready():
	assert(
		level_number != null and nb_coins != null, "init must be called before creating Level scene"
	)
	hud.set_level_number(level_number)
	hud.set_coins(nb_coins)
	hud.set_level_name(level_data.name)

	self.timer.start(self.level_data.timer_duration)


func init(level_data_p: LevelData, level_number, nb_coins):
	self.level_data = level_data_p
	self.level_number = level_number
	self.nb_coins = nb_coins


func _on_Timer_timeout():
	if randi() % 2:
		emit_signal("end_of_level")
	else:
		emit_signal("game_over")
