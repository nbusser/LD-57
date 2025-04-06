class_name CardsManager extends Node3D

const CARD_VERTICAL_OFFSET = Vector3.DOWN * 0.06
const CARD_THICKNESS = 0.0003  # .3mm

var _dragged_card: Card = null

@onready var card_scene: PackedScene = preload("res://src/Card/Card.tscn")
@onready var cards_in_hand: Node3D = $CardsInHand


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
