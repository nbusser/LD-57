extends Node

signal scene_ended(status: EndSceneStatus, params: Dictionary)
# Status sent along with signal end_scene()
enum EndSceneStatus {
	# Main meu
	MAIN_MENU_CLICK_START,
	MAIN_MENU_CLICK_SELECT_LEVEL,
	MAIN_MENU_CLICK_CREDITS,
	MAIN_MENU_CLICK_QUIT,
	# Level
	LEVEL_END,
	LEVEL_GAME_OVER,
	LEVEL_RESTART,
	# Game over screen
	GAME_OVER_RESTART,
	GAME_OVER_QUIT,
	# Score screen
	SCORE_SCREEN_NEXT,
	SCORE_SCREEN_RETRY,
	# Select level
	SELECT_LEVEL_SELECTED,
	SELECT_LEVEL_BACK,
	# Credits
	CREDITS_BACK,
}

const SAMPLE_GLOBAL_VARIABLE: int = 1

# gdlint: disable=duplicated-load
var card_skins: Dictionary = {
	-2: load("res://assets/sprites/card_placeholder.png"),
	0: load("res://assets/sprites/card_placeholder.png"),
	1: load("res://assets/sprites/card_placeholder.png"),
	2: load("res://assets/sprites/card_placeholder.png"),
	3: load("res://assets/sprites/card_placeholder.png"),
	4: load("res://assets/sprites/card_placeholder.png"),
	5: load("res://assets/sprites/card_placeholder.png"),
}
# gdlint: enable=duplicated-load


func end_scene(status: EndSceneStatus, params: Dictionary = {}) -> void:
	scene_ended.emit(status, params)
