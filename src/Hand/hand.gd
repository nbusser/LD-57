class_name Hand extends Node3D

var close_cards: Dictionary[int, Node3D] = {}
var closest_card: Node3D = null
var dirty = true

var enabled = false


func _on_grab_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("cards"):
		close_cards.set(body.get_instance_id(), body)
		dirty = true


func _on_grab_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("cards"):
		close_cards.erase(body.get_instance_id())
		dirty = true


func get_closest_card() -> Node3D:
	if not dirty:
		return closest_card

	closest_card = null
	var closest_distance: float = INF

	for card_id in close_cards.keys():
		var card = close_cards[card_id]
		var distance = get_position().distance_to(card.get_position())
		if distance < closest_distance:
			closest_card = card
			closest_distance = distance
	dirty = false
	return closest_card


func disable():
	self.visible = false
	enabled = false


func enable():
	self.visible = true
	enabled = true
