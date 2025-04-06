extends Node2D

@export var distance_constraint = 60.0
@export var reactivity = 50

var enabled = true

@onready var anchor = $"Anchor"
@onready var hand_body = $"HandBody"
@onready var arm = $"Arm"


func _ready() -> void:
	var points = arm.points
	for i in range(points.size()):
		points[i] = anchor.position + i * (hand_body.position - anchor.position) / points.size()
	arm.set_points(points)
	hand_body.position = Vector2(0, 0)


func _physics_process(delta: float) -> void:
	if !enabled:
		return

	# Move hand
	hand_body.velocity = (get_global_mouse_position() - hand_body.global_position) * 500 * delta
	if hand_body.move_and_slide():
		var collision_info = hand_body.get_last_slide_collision()
		var norm = collision_info.get_normal()
		var slide_dir = norm.rotated(PI / 2)
		var target = Geometry2D.line_intersects_line(
			hand_body.global_position, slide_dir, get_global_mouse_position(), norm
		)
		hand_body.velocity = (target - hand_body.global_position) * 500 * delta
		hand_body.move_and_slide()

	# Adjust arm length
	var required_length = (anchor.position - hand_body.position).length()
	if required_length / arm.points.size() > distance_constraint:  # Too short, emergency fix
		distance_constraint = required_length / arm.points.size()
	elif required_length / (arm.points.size() - 2) < distance_constraint:  # Too long, spool back slowly
		distance_constraint -= delta * reactivity
	if distance_constraint < required_length / (arm.points.size() - 1):  # Long enough but may be longer, grow slowly
		distance_constraint += delta * reactivity

	# Run FABRIK
	FABRIK_pass()


# gdlint:ignore = function-name
func FABRIK_pass():
	var points = arm.points

	# Backward
	points[0] = anchor.position  # Set the last node to the target position
	for i in range(1, points.size()):
		var new_direction = (points[i] - points[i - 1]).normalized()
		points[i] = points[i - 1] + new_direction * distance_constraint

	# Forward
	points[points.size() - 1] = hand_body.position  # Set the first node to the anchor position
	for i in range(points.size() - 2, -1, -1):
		var new_direction = (points[i + 1] - points[i]).normalized()
		points[i] = points[i + 1] - new_direction * distance_constraint

	arm.set_points(points)

	hand_body.global_rotation = points[points.size() - 2].angle_to_point(points[points.size() - 1])


func disable():
	self.visible = false
	enabled = false


func enable():
	_ready()
	self.visible = true
	enabled = true
