extends MeshInstance3D

signal card_collided(body)

func _on_body_entered(body):
	if body.is_in_group("cards"):
		emit_signal("card_collided", body)
