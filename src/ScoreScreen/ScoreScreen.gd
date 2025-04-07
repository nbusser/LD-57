class_name ScoreScreen

extends Control

var level_number: int

@onready var level_label = $CenterContainer/VBoxContainer/CenterContainer/HBoxContainer/LevelNumber


func _ready() -> void:
	assert(level_number != null, "init must be called before creating ScoreScreen scene")
	level_label.text = str(level_number + 1)


func init(level_number_p: int) -> void:
	self.level_number = level_number_p


func _on_NextLevelButton_pressed() -> void:
	Globals.end_scene(Globals.EndSceneStatus.SCORE_SCREEN_NEXT)
