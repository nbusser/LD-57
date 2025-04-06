extends Node3D

var glowing = false

@onready var camera: Camera3D = $"../CameraRail/FollowRail/Camera"
@onready var cards_manager: CardsManager = $"../CardsManager"
@onready var glowing_texture: Texture2D = load("res://assets/sprites/battlefield_glow.png")
@onready var base_texture: Texture2D = load("res://assets/sprites/battlefield.png")

func _ready() -> void:
	$Sprite3D.texture = base_texture


func _process(_delta: float) -> void:
	var is_close = cards_manager.is_card_close_to_battlefield()
	if is_close != glowing:
		glowing = is_close
		$Sprite3D.texture = glowing_texture if is_close else base_texture
