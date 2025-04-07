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
	#_cards_manager.spawn_cards_in_hand([0, -2, 3, 4, 4])

	#Pour le débug on start le round mtn
	var round_manager = _card_game.create_round_manager()

	round_manager.life_changed.connect(_on_life_changed)
	_enemy_snapper.set_modulate(Color(100, 0, 0))
	_enemy_snapper.init(false)
	_player_snapper.set_modulate(Color(0, 100, 0))
	_player_snapper.init(true)


func _on_life_changed(side: CardGame.Side, value: int):
	match side:
		CardGame.Side.ALIEN:
			_score_display_enemy.value = value
		CardGame.Side.PLAYER:
			_score_display_player.value = value


func _on_enemy_player_caught_cheating() -> void:
	print("GAME OVER BLOCK THE CONTROLS")
	#TODO : BLOCK THE CONTROLS
	Globals.action_state = Globals.ActionState.CAUGHT
	await get_tree().create_timer(3.0).timeout
	Globals.end_scene(Globals.EndSceneStatus.LEVEL_GAME_OVER)
