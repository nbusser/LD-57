class_name CardsManager extends Node3D

const CARD_VERTICAL_OFFSET = Vector3.DOWN * 0.06
const CARD_THICKNESS = 0.0003  # .3mm

var _dragged_card: Card = null

@onready var card_scene: PackedScene = preload("res://src/Card/Card.tscn")
@onready var cards_in_hand: Node3D = $CardsInHand
@onready var finger_tip: Node2D = $"../Billboard/2DHand/HandBody/Sprite2D/FingerTip"
@onready var camera: Camera3D = $"../CameraRail/FollowRail/Camera"
@onready var batte_field_zone: Node3D = $"../CardsInBattleField"
@onready var card_game: Node = $"../cardgame"


func _physics_process(_delta: float) -> void:
	# Move the dragged card along the finger tip
	if _dragged_card != null:
		_dragged_card.rotation = Vector3(PI / 2, 0, 0)
		var ray_origin = camera.project_ray_origin(finger_tip.global_position)
		var ray_end = ray_origin + camera.project_ray_normal(finger_tip.global_position) * 1

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end, 1 << 7)
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query).get("position")
		if result:
			_dragged_card.global_position = result
			_is_card_close_to_battlefield = (
				_dragged_card.global_position.distance_to(batte_field_zone.global_position) < 0.1
			)
		# _dragged_card.transform = _dragged_card.transform.translated(Vector3(0.0, -0.06, 0.0))


var _is_card_close_to_battlefield = false


func is_card_close_to_battlefield() -> bool:
	return _is_card_close_to_battlefield


func grab_card_in_hand(card: Card):
	_dragged_card = card
	_hand_remove_card(card)
	add_child(_dragged_card)
	card.start_dragging()


func place_card_in_battlefield(card: Card):
	card_game.round_manager.play_card("player", card.card_value)
	batte_field_zone.add_child(card)
	card.position = Vector3.ZERO
	card.remove_from_group("grabbable_cards")


func drop_card_in_hand():
	remove_child(_dragged_card)
	var close = is_card_close_to_battlefield()
	if close and card_game.current_state == card_game.GameState.PLAYER_TURN:
		print("Card dropped in battlefield")
		place_card_in_battlefield(_dragged_card)
	else:
		print("Card dropped in hand")
		_hand_add_card(_dragged_card, 0)

	_dragged_card.stop_dragging()
	_dragged_card = null


func spawn_cards(card_values: Array):
	for value in card_values:
		var card: Card = card_scene.instantiate()
		card.init(value)
		_hand_add_card(card, 0)
	_hand_reorder_cards()


func _hand_add_card(card: Card, index: int):
	card.add_to_group("grabbable_cards")
	cards_in_hand.add_child(card)
	cards_in_hand.move_child(card, index)
	_hand_reorder_cards()


func _hand_remove_card(card: Card):
	card.remove_from_group("grabbable_cards")
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
