extends Node

signal scene_ended(status: EndSceneStatus, params: Dictionary)
signal state_changed(action_state: ActionState, enemy_state: BaseEnemyState)
signal tutorial_mode_changed(tutorial_mode: bool)

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

const SAMPLE_GLOBAL_VARIABLE: int = 1

var dialog: Dialog = null

var card_skins: Dictionary = {
	-2: load("res://assets/sprites/cards/card_front_minus2.webp"),
	0: load("res://assets/sprites/cards/card_front_0.webp"),
	1: load("res://assets/sprites/cards/card_front_1.webp"),
	2: load("res://assets/sprites/cards/card_front_2.webp"),
	3: load("res://assets/sprites/cards/card_front_3.webp"),
	4: load("res://assets/sprites/cards/card_front_4.webp"),
	5: load("res://assets/sprites/cards/card_front_5.webp"),
}

var enemy_state = BaseEnemyState.IDLE:
	set(state):
		print("new enemy state ", state)
		state_changed.emit(action_state, state)
		enemy_state = state

var action_state = ActionState.IDLE:
	set(state):
		state_changed.emit(state, enemy_state)
		action_state = state

		match action_state:
			ActionState.IDLE:
				scene_manager.change_music_track_by_index(0)
			ActionState.ILLEGAL:
				scene_manager.change_music_track_by_index(1)
			ActionState.CAUGHT:
				scene_manager.change_music_track_by_index(3)

var tutorial_mode: bool = true:
	set(value):
		tutorial_mode_changed.emit(tutorial_mode)
		tutorial_mode = value

@onready var scene_manager = get_node("/root/SceneManager")


func end_scene(status: EndSceneStatus, params: Dictionary = {}) -> void:
	scene_ended.emit(status, params)


func set_dialog(dialog: Dialog) -> void:
	self.dialog = dialog


func show_messages(messages: Array[String], can_click = true) -> void:
	await dialog.show_messages(messages, can_click)


func wait_for_click():
	await dialog.wait_for_click()
