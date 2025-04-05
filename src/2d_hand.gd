extends Node2D

@onready var IntermediatePoints = get_node("IntermediatePoints")
@onready var Anchor = get_node("Anchor")
@onready var HandBody = get_node("HandBody")
@onready var Arm = get_node("Arm")

@export var distance_constraint = 60.0
@export var reactivity = 50

var enabled = true

func _ready() -> void:
	var points = Arm.points
	for i in range(points.size()):
		points[i] = Anchor.position + i*(HandBody.position - Anchor.position)/points.size()
	Arm.set_points(points)
	HandBody.position = Vector2(0, 0)

func _physics_process(delta: float) -> void:
	if !enabled:
		return
	
	# Move hand
	HandBody.velocity = (get_global_mouse_position() - HandBody.global_position)*500*delta
	if HandBody.move_and_slide():
		var collision_info = HandBody.get_last_slide_collision()
		var norm = collision_info.get_normal()
		var slide_dir = norm.rotated(PI/2)
		var target = Geometry2D.line_intersects_line(HandBody.global_position, slide_dir, get_global_mouse_position(), norm)
		HandBody.velocity = (target - HandBody.global_position)*500*delta
		HandBody.move_and_slide()
	
	# Adjust arm length
	var required_length = (Anchor.position - HandBody.position).length()
	if required_length/Arm.points.size() > distance_constraint: # Too short, emergency fix
		distance_constraint = required_length/Arm.points.size()
	elif required_length/(Arm.points.size() - 2) < distance_constraint: # Too long, spool back slowly
		distance_constraint -= delta*reactivity
	if distance_constraint < required_length/(Arm.points.size() - 1): # Long enough but may be longer, grow slowly
		distance_constraint += delta*reactivity
	
	# Run FABRIK
	FABRIK_pass()

func FABRIK_pass():
	var points = Arm.points
	
	# Backward
	points[0] = Anchor.position  # Set the last node to the target position
	for i in range(1, points.size()):
		var new_direction = (points[i] - points[i - 1]).normalized()
		points[i] = points[i - 1] + new_direction*distance_constraint
	
	# Forward
	points[points.size() - 1] = HandBody.position  # Set the first node to the anchor position
	for i in range(points.size() - 2, -1, -1):
		var new_direction = (points[i + 1] - points[i]).normalized()
		points[i] = points[i + 1] - new_direction*distance_constraint
	
	Arm.set_points(points)
	
	HandBody.global_rotation = points[points.size() - 2].angle_to_point(points[points.size() - 1])

func disable():
	self.visible = false
	enabled = false

func enable():
	_ready()
	self.visible = true
	enabled = true
