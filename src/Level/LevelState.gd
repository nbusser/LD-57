class_name LevelState

extends Resource

# Represents the state of the level
# Carries the level configuration but also holds game context information

var level_number: int = 0
var level_data: LevelData  # Config of the level


func _init(level_number_p: int, level_data_p: LevelData):
	self.level_number = level_number_p
	self.level_data = level_data_p
