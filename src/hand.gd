extends Node3D

signal card_collided(body)


func _on_grab_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("cards"):
		emit_signal("card_collided", body)
