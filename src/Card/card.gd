class_name Card extends StaticBody3D

enum State { NOTHING = 0, HOVERED = 1, DRAGGED = 2 }

const _INT_MIN_SENTINEL_VALUE = -100000
const RATIO = .0221 / 430

@export var card_value: int = _INT_MIN_SENTINEL_VALUE

var _card_state: State = State.NOTHING

var _is_in_sleeve_mode = false
var _is_in_hand_mode = false

@onready var _card_face_sprite: Sprite3D = $"Visuals/FaceSprite"
@onready var _card_border_sprite: Sprite3D = $"Visuals/BorderSprite"
@onready var _visuals: Node3D = $"Visuals"


# Hides the mesh, billboards the sprite
func sleeve_mode(enable: bool):
	_is_in_sleeve_mode = enable
	if enable:
		_card_border_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	else:
		_card_border_sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED

	_card_face_sprite.visible = not enable
	start_hovering()


func hand_mode(enable: bool):
	_is_in_hand_mode = enable
	_visuals.position = Vector3.ZERO


func _process(_delta: float) -> void:
	if _is_in_sleeve_mode:
		start_hovering()


func start_hovering():
	_card_state = State.HOVERED
	_card_border_sprite.set_layer_mask_value(6, true)
	if _is_in_hand_mode:
		var tween = create_tween()
		tween.tween_property(_visuals, "position", Vector3.FORWARD * .05, .2)


func stop_hovering():
	_card_state = State.NOTHING
	_card_border_sprite.set_layer_mask_value(6, false)
	if _is_in_hand_mode:
		var tween = create_tween()
		tween.tween_property(_visuals, "position", Vector3.ZERO, .2)


func start_dragging():
	stop_hovering()
	_card_state = State.DRAGGED
	_visuals.position = Vector3.ZERO


func stop_dragging():
	_card_state = State.NOTHING
	_visuals.position = Vector3.ZERO


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
	assert(
		abs(size.x / size.y - 1.0 / 1.0) < 0.01,
		"Texture aspect ratio must be 1/1 but was %s" % str(size.x / size.y)
	)

	_card_face_sprite.texture = card_texture
	# _card_face_sprite.scale = Vector3.ONE * RATIO * size.y


func init(card_value_arg: int):
	card_value = card_value_arg
