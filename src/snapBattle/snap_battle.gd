extends Node3D

var glowing = false
var is_player = false
var is_playing = true

@onready var camera: Camera3D = $"../CameraRail/FollowRail/Camera"
@onready var cards_manager: CardsManager = $"../CardsManager"
@onready var glowing_texture: Texture2D = load("res://assets/sprites/battlefield_glow.png")
@onready var base_texture: Texture2D = load("res://assets/sprites/battlefield.png")
@onready var sprite = $Sprite3D


func _ready() -> void:
	$Sprite3D.texture = base_texture


func init(is_player: bool):
	self.is_player = is_player


func _process(_delta: float) -> void:
	var is_close = cards_manager.is_card_close_to_battlefield()
	if is_player:
		if !is_playing:
			sprite.modulate = Color(1, 0, 0, 1)
		elif is_close:
			sprite.modulate = Color(1, 1, 0, 1)
		else:
			sprite.modulate = Color(0, 1, 0, 1)
	else:
		sprite.modulate = Color(1, 0, 0, 1)
