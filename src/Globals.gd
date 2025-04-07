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
	-2: load("res://assets/sprites/cards/sprite_0.png"),
	0: load("res://assets/sprites/cards/sprite_1.png"),
	1: load("res://assets/sprites/cards/sprite_2.png"),
	2: load("res://assets/sprites/cards/sprite_4.png"),
	3: load("res://assets/sprites/cards/sprite_5.png"),
	4: load("res://assets/sprites/cards/sprite_6.png"),
	5: load("res://assets/sprites/cards/sprite_8.png"),
}
# gdlint: enable=duplicated-load


func end_scene(status: EndSceneStatus, params: Dictionary = {}) -> void:
	scene_ended.emit(status, params)


enum BaseEnemyState {
	IDLE,
	DISTRACTED,
	SUSPICIOUS,
	ANGRY,
}

enum ActionState {
	IDLE,
	ILLEGAL,
	CAUGHT,
}

signal state_changed(action_state: ActionState, enemy_state: BaseEnemyState)

var enemy_state = BaseEnemyState.IDLE
var action_state = ActionState.IDLE


func set_enemy_state(state: BaseEnemyState) -> void:
	if state == BaseEnemyState.IDLE:
		state_changed.emit(action_state, BaseEnemyState.IDLE)
	elif state == BaseEnemyState.DISTRACTED:
		state_changed.emit(action_state, BaseEnemyState.DISTRACTED)
	elif state == BaseEnemyState.SUSPICIOUS:
		state_changed.emit(action_state, BaseEnemyState.SUSPICIOUS)
	elif state == BaseEnemyState.ANGRY:
		state_changed.emit(action_state, BaseEnemyState.ANGRY)
	enemy_state = state


func set_action_state(state: ActionState) -> void:
	if state == ActionState.IDLE:
		state_changed.emit(ActionState.IDLE, enemy_state)
	elif state == ActionState.ILLEGAL:
		state_changed.emit(ActionState.ILLEGAL, enemy_state)
	elif state == ActionState.CAUGHT:
		state_changed.emit(ActionState.CAUGHT, enemy_state)
	action_state = state
