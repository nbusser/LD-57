extends Node2D

@onready var IntermediatePoints = get_node("IntermediatePoints")
@onready var Anchor = get_node("Anchor")
@onready var Hand = get_node("HandBody")
@onready var Arm = get_node("Arm")

@export var distance_constraint = 60.0
@export var reactivity = 10

func _ready() -> void:
	var points = Arm.points
	for i in range(points.size()):
		points[i] = Anchor.position + i*(Hand.position - Anchor.position)/points.size()
	Arm.set_points(points)

func _process(delta: float) -> void:
	Hand.position = get_global_mouse_position()
	fABRIK_pass()
	# Adjust arm length
	var required_length = (Anchor.position - Hand.position).length()
	if required_length/Arm.points.size() > distance_constraint:
		distance_constraint = required_length/(Arm.points.size() - 1)
	elif required_length/Arm.points.size() < distance_constraint:
		distance_constraint -= delta*reactivity

func fABRIK_pass():
	var points = Arm.points
	
	# Forward
	points[points.size() - 1] = Hand.position  # Set the first node to the anchor position
	for i in range(points.size() - 2, -1, -1):
		var new_direction = (points[i + 1] - points[i]).normalized()
		points[i] = points[i + 1] - new_direction*distance_constraint
	
	# Backward
	points[0] = Anchor.position  # Set the last node to the target position
	for i in range(1, points.size()):
		var new_direction = (points[i] - points[i - 1]).normalized()
		points[i] = points[i - 1] + new_direction*distance_constraint
	
	Arm.set_points(points)
