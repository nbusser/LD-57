class_name Sleeve extends Node2D

signal finger_entered_sleeve
signal finger_left_sleeve

var finger_is_in_sleeve = false


func _on_drop_zone_body_entered(_body: Node2D) -> void:
	Globals.action_state = Globals.ActionState.ILLEGAL
	finger_is_in_sleeve = true
	finger_entered_sleeve.emit()


func _on_drop_zone_body_exited(_body: Node2D) -> void:
	Globals.action_state = Globals.ActionState.IDLE
	finger_is_in_sleeve = false
	finger_left_sleeve.emit()
