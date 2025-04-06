class_name CardsManager extends Node3D

const CARD_VERTICAL_OFFSET = Vector3.DOWN * 0.06
const CARD_THICKNESS = 0.0003  # .3mm

var _dragged_card: Card = null

@onready var card_scene: PackedScene = preload("res://src/Card/Card.tscn")
@onready var cards_in_hand: Node3D = $CardsInHand
@onready var finger_tip: Node2D = $"../2DHand/HandBody/Sprite2D/FingerTip"
@onready var camera: Camera3D = $"../CameraRail/FollowRail/Camera"


func _physics_process(_delta: float) -> void:
	# Move the dragged card along the finger tip
	if _dragged_card != null:
		_dragged_card.global_position = (
			camera.project_ray_origin(finger_tip.global_position)
			+ camera.project_ray_normal(finger_tip.global_position) * 0.3
		)


func grab_card_in_hand(card: Card):
	_dragged_card = card
	_hand_remove_card(card)
	add_child(_dragged_card)
	card.start_dragging()


func drop_card_in_hand(card: Card):
	_dragged_card = null
	remove_child(card)
	_hand_add_card(card, 0)
	card.stop_dragging()


func spawn_cards(num_cards: int):
	for i in range(num_cards):
		var card: Card = card_scene.instantiate()
		var card_value = 1
		card.init(card_value)
		card.add_to_group("cards")
		cards_in_hand.add_child(card)
	_hand_reorder_cards()


func _hand_add_card(card: Card, index: int):
	cards_in_hand.add_child(card)
	cards_in_hand.move_child(card, index)
	_hand_reorder_cards()


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

		var angle = start_angle + (angle_step * i)
		card.position = Vector3.ZERO
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
