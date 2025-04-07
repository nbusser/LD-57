class_name CardsManager extends Node3D

const CARD_VERTICAL_OFFSET = Vector3.DOWN * 0.06
const CARD_THICKNESS = 0.003  # .3mm

var _is_card_close_to_battlefield = false

var _grabbed_card: Card:
	get:
		assert(_grabbed_card_parent.get_child_count() <= 1)
		return (
			null
			if _grabbed_card_parent.get_child_count() == 0
			else _grabbed_card_parent.get_child(0)
		)
	set(card):
		if card == null:
			assert(_grabbed_card_parent.get_child_count() == 1)
			_grabbed_card_parent.remove_child(_grabbed_card_parent.get_child(0))
		else:
			assert(_grabbed_card_parent.get_child_count() == 0)
			_grabbed_card_parent.add_child(card)

@onready var card_scene: PackedScene = preload("res://src/Card/Card.tscn")
@onready var finger_tip: Node2D = $"../2DHand/HandBody/Sprite2D/FingerTip"
@onready var camera: Camera3D = $"../CameraRail/FollowRail/Camera"
@onready var drop_zone_player: Node3D = $"../Snapper/CardsInBattleField"
@onready var card_game: Node = $"../cardgame"
@onready var sleeve: Sleeve = $"../Billboard/Sleeve"

@onready var cards_in_hand: Node3D = $SleeveHand/CardsInHand
@onready var cards_on_top_of_deck: Node3D = $CardsOnTopOfDeck
@onready var _cards_on_sleeve: Node3D = $CardsInSleeve
@onready var _grabbed_card_parent: Node3D = $"GrabbedCard"


func is_grabbing_a_card():
	return _grabbed_card != null


func _physics_process(_delta: float) -> void:
	# Move the dragged card along the finger tip
	if _grabbed_card != null:
		_grabbed_card.rotation = Vector3(PI / 2, 0, 0)
		var ray_origin = camera.project_ray_origin(finger_tip.global_position)
		var ray_end = ray_origin + camera.project_ray_normal(finger_tip.global_position) * 1

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end, 1 << 7)
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query).get("position")
		if result:
			_grabbed_card.global_position = result
			_is_card_close_to_battlefield = (
				_grabbed_card.global_position.distance_to(drop_zone_player.global_position) < 0.1
			)
		# _dragged_card.transform = _dragged_card.transform.translated(Vector3(0.0, -0.06, 0.0))


func is_card_close_to_battlefield() -> bool:
	return _is_card_close_to_battlefield


func grab_card(card: Card):
	assert(_grabbed_card == null, "Cannot grab a card if you already have a card in hand")

	card.visible = true
	card.remove_from_group("grabbable_cards")

	# Card was in hand
	if card.get_parent() == cards_in_hand:
		_hand_remove_card(card)
	# Card was in deck
	elif card.get_parent() == cards_on_top_of_deck:
		cards_on_top_of_deck.remove_child(card)
	# Card was in sleeve
	elif card.get_parent() == _cards_on_sleeve:
		_cards_on_sleeve.remove_child(card)
		card.sleeve_mode(false)

	_grabbed_card = card
	card.start_dragging()


func _place_card_in_battlefield(card: Card):
	card_game.round_manager.play_card("player", card.card_value)
	drop_zone_player.add_child(card)
	card.position = Vector3.ZERO
	card.remove_from_group("grabbable_cards")


func drop_card():
	assert(_grabbed_card != null, "Cannot drop card if no card in hand")

	var card = _grabbed_card
	card.stop_dragging()
	var old_transform = card.global_transform
	_grabbed_card = null

	if sleeve.finger_is_in_sleeve:
		print("Card dropped in sleeve")
		_sleeve_add_card(card)
	else:
		var close = is_card_close_to_battlefield()
		if close and card_game.current_state == card_game.GameState.PLAYER_TURN:
			print("Card dropped in battlefield")
			_place_card_in_battlefield(card)
		else:
			print("Card dropped in hand")
			_hand_add_card(card, 0, old_transform)


# -------- SLEEVE RELATED ACTIONS --------


func _sleeve_add_card(card: Card):
	card.sleeve_mode(true)
	_cards_on_sleeve.add_child(card)
	card.add_to_group("grabbable_cards")


func _sleeve_remove_card(card: Card):
	card.sleeve_mode(false)
	_cards_on_sleeve.remove_child(card)


# -------- HAND RELATED ACTIONS --------


func spawn_cards_in_hand(card_values: Array):
	for value in card_values:
		var card: Card = card_scene.instantiate()
		card.init(value)
		_hand_add_card(card, 0, Transform3D.IDENTITY)
	_hand_reorder_cards()


func _hand_add_card(card: Card, index: int, og_transform: Transform3D):
	card.add_to_group("grabbable_cards")
	cards_in_hand.add_child(card)
	cards_in_hand.move_child(card, index)
	_hand_reorder_cards()

	if og_transform != Transform3D.IDENTITY:
		var target_trans = card.global_transform
		card.global_transform = og_transform
		create_tween().tween_property(card, "global_transform", target_trans, .5)


func _hand_remove_card(card: Card):
	cards_in_hand.remove_child(card)
	_hand_reorder_cards()


func _hand_reorder_cards():
	var num_cards = len(cards_in_hand.get_children())

	var angle_step = PI / 12
	var total_angle = angle_step * num_cards
	var start_angle = -total_angle / 2

	for i in range(num_cards):
		var card: Card = cards_in_hand.get_child(i)
		card.position = Vector3.ZERO
		card.rotation = Vector3.ZERO

		var angle = start_angle + (angle_step * i)

		card.transform = card.transform.rotated_local(Vector3.LEFT, PI / 2)
		card.transform = (
			card
			. transform
			. translated(-CARD_VERTICAL_OFFSET)
			. rotated(Vector3.FORWARD, angle)
			. translated(CARD_VERTICAL_OFFSET)
			. translated(Vector3.BACK * CARD_THICKNESS * i)
			. rotated_local(Vector3.RIGHT, PI)
		)
