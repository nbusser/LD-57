extends Node3D

@onready var msg = $"Bubble/Label3D"


func _ready() -> void:
	msg.text = "Hey you! Come closer."
