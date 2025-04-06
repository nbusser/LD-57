extends Node3D

const PLANE_COLLISION_LAYER = 6

var _hovered_card: Card = null
var _dragged_card: Card = null

@onready var cards_hand: CardHand = $CardHand
@onready var card_scene: PackedScene = preload("res://src/Card/Card.tscn")
@onready var finger_tip = $"2DHand/HandBody/Sprite2D/FingerTip"
@onready var sprite = $"2DHand/HandBody/Sprite2D"

@onready var stencil_viewport: SubViewport = $StencilViewport
@onready var stencil_camera: Camera3D = $StencilViewport/Camera3D


func _is_dragging():
	return _dragged_card != null


func _process(_delta):
	var viewport := get_viewport()
	var current_camera := viewport.get_camera_3d()

	if stencil_viewport.size != viewport.size:
		stencil_viewport.size = viewport.size

	if current_camera:
		stencil_camera.fov = current_camera.fov
		stencil_camera.global_transform = current_camera.global_transform

	if _is_dragging():
		return

	var new_hover_card: Card = null
	new_hover_card = finger_tip.get_closest_card()

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
				_dragged_card = _hovered_card
				_dragged_card.start_dragging()
				_hovered_card = null
				sprite.frame = 1
		else:
			if _dragged_card != null:
				_dragged_card.stop_dragging()
				_dragged_card = null
				# TODO: drop the card
				sprite.frame = 0


func _ready():
	cards_hand.spawn_cards(5)
