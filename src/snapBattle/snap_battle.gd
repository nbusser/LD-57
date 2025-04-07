extends Node3D

var glowing = false
var base_modulate = Color(0, 0, 0)
var is_player = false

@onready var camera: Camera3D = $"../CameraRail/FollowRail/Camera"
@onready var cards_manager: CardsManager = $"../CardsManager"
@onready var glowing_texture: Texture2D = load("res://assets/sprites/battlefield_glow.png")
@onready var base_texture: Texture2D = load("res://assets/sprites/battlefield.png")
@onready var sprite = $Sprite3D


func set_modulate(color):
	base_modulate = color
	if !glowing || !is_player:
		sprite.modulate = color


func _ready() -> void:
	$Sprite3D.texture = base_texture


func init(is_player: bool):
	self.is_player = is_player


func _process(_delta: float) -> void:
	var is_close = cards_manager.is_card_close_to_battlefield()
	if is_player && is_close != glowing:
		glowing = is_close
		print("Disagree")
		if is_close:
			sprite.modulate = Color(100, 100, 0)
		else:
			sprite.modulate = base_modulate
		$Sprite3D.texture = glowing_texture if is_close else base_texture
