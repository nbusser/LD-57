extends Node2D

@export var distance_constraint = 60.0
@export var reactivity = 5000
@export var joint_speed = 2000

var joints = []

var state: Enums.HandState = Enums.HandState.POINT:
	set(value):
		state = value
		_on_update_state()

var can_control = true

@onready var anchor = $"Anchor"
@onready var hand_body = $"HandBody"
@onready var arm = $"Arm"
@onready var finger_tip = $"HandBody/Sprite2D/FingerTip"
@onready var sprite_2d: AnimatedSprite2D = $"HandBody/Sprite2D"
@onready var attachment_point = $HandBody/AttachmentPoint

@onready var point_outline: Line2D = $HandBody/Sprite2D/PointOutline
@onready var pinch_outline: Node2D = $HandBody/Sprite2D/PinchOutline
@onready var point_collision: CollisionPolygon2D = $HandBody/PointCollision
@onready var pinch_collision: CollisionPolygon2D = $HandBody/PinchCollision


func _ready() -> void:
	var points = arm.points
	for i in range(points.size()):
		points[i] = (
			anchor.global_position
			+ i * (attachment_point.global_position - anchor.global_position) / points.size()
		)
	arm.set_points(points)
	for i in range(points.size()):
		var node = CharacterBody2D.new()
		node.name = "Joint" + str(i)
		node.global_position = points[i]
		var collision_shape = CollisionShape2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = 20
		collision_shape.shape = circle_shape
		node.collision_layer = 2
		node.add_child(collision_shape)
		arm.add_child(node)
		joints.append(node)
	joints[joints.size() - 1].collision_layer = 0

	_on_update_state()


func _physics_process(delta: float) -> void:
	#Adjust display size
	hand_body.scale.x = clamp(1.0 - finger_tip.distance / 2.0, .1, 1.0)
	hand_body.scale.y = clamp(1.0 - finger_tip.distance / 2.0, .1, 1.0)
	arm.width_curve.set_point_value(1, .2 + clamp(1.0 - finger_tip.distance / 2.0, .1, 1.0))

	# Move
	if can_control:
		hand_body.velocity = (
			(get_global_mouse_position() - finger_tip.global_position) * 500 * delta
		)
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
	elif required_length / arm.points.size() < distance_constraint:  # Too long, spool back slowly
		distance_constraint -= delta * reactivity

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
	joints[joints.size() - 1].global_position = attachment_point.global_position  # Set the first node to the anchor position
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
	#hand_body.global_rotation = points[points.size() - 2].angle_to_point(points[points.size() - 1])


func _on_update_state():
	point_outline.hide()
	pinch_outline.hide()

	#point_collision.disabled = true
	#pinch_collision.disabled = true

	match state:
		Enums.HandState.POINT:
			sprite_2d.frame = 0
			point_outline.show()
			#point_collision.disabled = false
		Enums.HandState.PINCH:
			sprite_2d.frame = 1
			pinch_outline.show()
			#pinch_collision.disabled = false
