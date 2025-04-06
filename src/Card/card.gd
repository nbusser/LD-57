class_name Card extends StaticBody3D

enum State { NOTHING = 0, HOVERED = 1, DRAGGED = 2 }

const _INT_MIN_SENTINEL_VALUE = -100000

@export var card_value: int = _INT_MIN_SENTINEL_VALUE

var _card_state: State = State.NOTHING

@onready var _card_face_sprite = $"FaceSprite"
@onready var _mesh = $CardMesh


func start_hovering():
	_card_state = State.HOVERED
	_mesh.set_layer_mask_value(6, true)


func stop_hovering():
	_card_state = State.NOTHING
	_mesh.set_layer_mask_value(6, false)


func start_dragging():
	stop_hovering()
	_card_state = State.DRAGGED


func stop_dragging():
	_card_state = State.NOTHING


func _ready():
	assert(
		card_value != _INT_MIN_SENTINEL_VALUE,
		"Card value has not been set. Call init() or set the card value in the inspector."
	)
	assert(
		card_value in Globals.card_skins,
		"Card with value {card_value} is not declared in Globals.card_skins"
	)

	var card_texture: CompressedTexture2D = Globals.card_skins[card_value]
	var size: Vector2 = card_texture.get_size()
	assert(size == Vector2(518, 800), "Texture must be 518x800 (found {size})")

	_card_face_sprite.texture = card_texture


func init(card_value_arg: int):
	card_value = card_value_arg
