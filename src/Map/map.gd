extends Node3D

const PLANE_COLLISION_LAYER = 6

var _hovered_card: Card = null

@onready var _card_game: CardGame = $cardgame
@onready var _cards_manager: CardsManager = $CardsManager
@onready var _card_scene: PackedScene = preload("res://src/Card/Card.tscn")
@onready var _finger_tip = $"2DHand/HandBody/Sprite2D/FingerTip"
@onready var _hand_2d = $"2DHand"

@onready var _stencil_viewport: SubViewport = $StencilViewport
@onready var _stencil_camera: Camera3D = $StencilViewport/Camera3D

@onready var _score_display_enemy = $ScoreDisplayEnemy
@onready var _score_display_player = $ScoreDisplayPlayer

@onready var _player_snapper = $Snapper
@onready var _enemy_snapper = $EnemySnapper
@onready var _enemy: Enemy = $Enemy
@onready var _hud: HUD = $"../UI/HUD"

@onready var _round_manager = _card_game.create_round_manager()


func _process(_delta):
	var viewport := get_viewport()
	var current_camera := viewport.get_camera_3d()

	if _stencil_viewport.size != viewport.size:
		_stencil_viewport.size = viewport.size

	if current_camera:
		_stencil_camera.fov = current_camera.fov
		_stencil_camera.global_transform = current_camera.global_transform

	if _cards_manager.is_grabbing_a_card():
		pass
	else:
		var new_hover_card: Card = null
		new_hover_card = _finger_tip.get_closest_card()

		if new_hover_card == null:
			if _hovered_card != null:
				_hovered_card.stop_hovering()
				_hovered_card = null
		else:
			if _hovered_card == null:
				_hovered_card = new_hover_card
				_hovered_card.start_hovering()
			elif new_hover_card != _hovered_card:
				_hovered_card.stop_hovering()
				new_hover_card.start_hovering()
				_hovered_card = new_hover_card


func _input(event):
	# Dragging/dropping a card
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			if _hovered_card != null:
				_cards_manager.grab_card(_hovered_card)
				_hovered_card = null
				_hand_2d.state = Enums.HandState.PINCH
		else:
			if _cards_manager.is_grabbing_a_card():
				_cards_manager.drop_card()
				_hand_2d.state = Enums.HandState.POINT


func _ready():
	Globals.tutorial_mode_changed.connect(_on_tutorial_mode_changed)
	_on_tutorial_mode_changed(Globals.tutorial_mode)


func _on_tutorial_mode_changed(is_tutorial: bool) -> void:
	if is_tutorial:
		await tutorial()
	else:
		_round_manager.life_changed.connect(_on_life_changed)
		_enemy_snapper.init(false)
		_player_snapper.init(true)


func tutorial():
	await (
		Globals
		. show_messages(
			[
				"Hi, welcome to the introductory abduction program.",
				"You have been forcefully invited in the depths of your interstellar space to participate in the federation's intelligence test.",
				"You have been selected to represent your species:\nWater-Based-Carbon-Unit-42198",
				"You will be tested on your extra-sensory perception and multiverse-reasoning.",
				"We have materialized the standard test in a form you should be familiar with.",
				"The goal is to play lower-valued cards than the ones I play.",
				"Let's start with a simple example.",
				"Draw a card from the deck.",
			]
		)
	)
	# highlight the deck and wait for the player to draw a card

	await Globals.show_messages(['I will now play a "3" card.'])
	_card_game.current_state = CardGame.GameState.ALIEN_TURN
	await (
		Globals
		. show_messages(
			[
				"If you play a higher value (x) card , you will lose x - 3 points.",
				"Otherwise, I get to lose that difference.",
				"Your goal is to use your species' extra-sensory perception to predict my next moves and the deck's content.",
			]
		)
	)

	# Globals.enemy_state = Globals.BaseEnemyState.DISTRACTED
	_enemy.state = Enums.EnemyState.DISTRACTED
	await (
		Globals
		. show_messages(
			[
				"A supernova? Where?\n--The alien seems distracted--",
			]
		)
	)
	await Globals.show_messages(
		["--You can use this chance to reach the inside of your sleeve.\nTry it now.--"], false
	)

	# TODO disable death
	while true:
		var action_state = (await Globals.state_changed)[0]
		if action_state == Globals.ActionState.ILLEGAL:
			break
	_enemy.state = Enums.EnemyState.IDLE
	await (
		Globals
		. show_messages(
			[
				"--Good job!--",
				"--Did you notice the red glow when trying to cheat?--",
			]
		)
	)
	await (
		Globals
		. show_messages(
			[
				"Now ",
			]
		)
	)


func _on_life_changed(side: CardGame.Side, value: int):
	match side:
		CardGame.Side.ALIEN:
			_score_display_enemy.value = value
		CardGame.Side.PLAYER:
			_score_display_player.value = value


func _on_enemy_player_caught_cheating() -> void:
	if Globals.tutorial_mode:
		return
	Globals.action_state = Globals.ActionState.CAUGHT
	await _end_game_animation()
	Globals.end_scene(Globals.EndSceneStatus.LEVEL_GAME_OVER)


func _on_cardgame_player_lost() -> void:
	Globals.show_messages(["I won!"])
	await _end_game_animation()
	Globals.end_scene(Globals.EndSceneStatus.LEVEL_GAME_OVER)


func _on_cardgame_player_won() -> void:
	Globals.show_messages(["Daw zetla tah khedamin ta3 had jeu!"])
	await _end_game_animation()
	Globals.end_scene(Globals.EndSceneStatus.LEVEL_END)


func _end_game_animation():
	_hand_2d.can_control = false
	await get_tree().create_timer(0.5).timeout
	await _hud.fadeout()
