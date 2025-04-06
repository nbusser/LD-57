class_name CardHand extends Node2D

const CARD_VERTICAL_OFFSET = Vector3.DOWN * 0.06
const CARD_THICKNESS = 0.0003  # .3mm

@onready var card_scene: PackedScene = preload("res://src/Card/Card.tscn")
@onready var cards: Node3D = $Cards


func spawn_cards(num_cards: int):
	for i in range(num_cards):
		var card: Card = card_scene.instantiate()
		var card_value = 1
		card.init(card_value)
		card.add_to_group("cards")
		cards.add_child(card)
	_reorder_cards()


func add_card(card: Card, index: int):
	cards.add_child(card)
	cards.move_child(card, index)
	_reorder_cards()


func remove_card(index: int):
	var card = cards.get_child(index)
	cards.remove_child(card)
	_reorder_cards()


func _reorder_cards():
	var num_cards = len(cards.get_children())

	var angle_step = PI / 12
	var total_angle = angle_step * num_cards
	var start_angle = -total_angle / 2

	for i in range(num_cards):
		var card: Card = cards.get_child(i)

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
			. translated(Vector3.BACK * .001 * i)
		)
