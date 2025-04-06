extends Node2D

@export var rail_ratio_speed = .1
var forward = true
@onready var follow_rail = get_node("..")


func _process(delta: float) -> void:
	follow_rail.progress_ratio += delta * rail_ratio_speed * (1 if forward else -1)
	if follow_rail.progress_ratio > .99:
		follow_rail.progress_ratio = .99
		forward = false
	if follow_rail.progress_ratio < .01:
		follow_rail.progress_ratio = .01
		forward = true
