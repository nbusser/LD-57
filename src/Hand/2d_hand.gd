extends Node2D

@export var distance_constraint = 60.0
@export var reactivity = 50
@export var joint_speed = 2000

var enabled = true
var joints = []

@onready var anchor = $"AnchorRail/AnchorFollowRail/Anchor"
@onready var hand_body = $"HandBody"
@onready var arm = $"Arm"
@onready var finger_tip = $"HandBody/Sprite2D/FingerTip"


func _ready() -> void:
	var points = arm.points
	for i in range(points.size()):
		points[i] = (
			anchor.global_position
			+ i * (hand_body.global_position - anchor.global_position) / points.size()
		)
	arm.set_points(points)
	hand_body.position = Vector2(0, 0)
	for i in range(points.size()):
		var node = CharacterBody2D.new()
		node.name = "Joint" + str(i)
		node.global_position = points[i]
		var collision_shape = CollisionShape2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = 10
		collision_shape.shape = circle_shape
		node.collision_layer = 2
		node.add_child(collision_shape)
		arm.add_child(node)
		joints.append(node)


func _physics_process(delta: float) -> void:
	if !enabled:
		return

	# Move
	hand_body.velocity = (get_global_mouse_position() - finger_tip.global_position) * 500 * delta
	if hand_body.move_and_slide():
		var collision_info = hand_body.get_last_slide_collision()
		var norm = collision_info.get_normal()
		var slide_dir = norm.rotated(PI / 2)
		var target = Geometry2D.line_intersects_line(
			finger_tip.global_position, slide_dir, get_global_mouse_position(), norm
		)
		hand_body.velocity = (target - finger_tip.global_position) * 500 * delta
		hand_body.move_and_slide()

	# Adjust arm length
	var required_length = (anchor.global_position - hand_body.position).length()
	if required_length / arm.points.size() > distance_constraint:  # Too short, emergency fix
		distance_constraint = required_length / arm.points.size()
	elif required_length / (arm.points.size() - 2) < distance_constraint:  # Too long, spool back slowly
		distance_constraint -= delta * reactivity
	if distance_constraint < required_length / (arm.points.size() - 1):  # Long enough but may be longer, grow slowly
		distance_constraint += delta * reactivity

	# Run FABRIK
	FABRIK_pass(delta)


# gdlint:ignore = function-name
func FABRIK_pass(delta: float):
	# Backward
	joints[0].global_position = anchor.global_position  # Set the last node to the target position
	for i in range(1, joints.size()):
		var new_direction = (joints[i].position - joints[i - 1].position).normalized()
		joints[i].velocity = (
			joint_speed
			* delta
			* ((joints[i - 1].position + new_direction * distance_constraint) - joints[i].position)
		)
		joints[i].move_and_slide()

	# Forward
	joints[joints.size() - 1].global_position = hand_body.global_position  # Set the first node to the anchor position
	for i in range(joints.size() - 2, -1, -1):
		var new_direction = (joints[i + 1].position - joints[i].position).normalized()
		joints[i].velocity = (
			joint_speed
			* delta
			* ((joints[i + 1].position - new_direction * distance_constraint) - joints[i].position)
		)
		joints[i].move_and_slide()

	var points = []
	for i in range(joints.size()):
		points.append(joints[i].position)
	arm.set_points(points)

	hand_body.global_rotation = points[points.size() - 2].angle_to_point(points[points.size() - 1])


func disable():
	self.visible = false
	enabled = false


func enable():
	_ready()
	self.visible = true
	enabled = true
