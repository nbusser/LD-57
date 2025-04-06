extends Node3D

@export var distance_constraint = 0.00001
@export var reactivity = .01
@export var joint_speed = 2000
@export var dist_out : float = 1

var joints = []
var pointed_location = Vector3()
var pointed_direction = Vector3()

@onready var anchor = $"Anchor"
@onready var hand_body = $"HandBody"
@onready var arm = $"Arm"
@onready var finger_tip = $"HandBody/Sprite2D/FingerTip"
@onready var joints_storage = $"Joints"
@onready var camera = get_node("../CameraRail/FollowRail/Camera")

const HAND_LAYER = 8

func _ready() -> void:
	var points = arm.points
	for i in range(points.size()):
		points[i] = (
			anchor.coords_2D
			+ i * (hand_body.coords_2D - anchor.coords_2D) / points.size()
		)
	arm.set_points(points)
	
	for i in range(points.size()):
		var node = CharacterBody3D.new()
		node.name = "Joint" + str(i)
		var collision_shape = CollisionShape3D.new()
		var sphere_shape = SphereShape3D.new()
		sphere_shape.radius = .01
		collision_shape.shape = sphere_shape
		node.collision_layer = 0
		var mesh = MeshInstance3D.new()
		mesh.mesh = BoxMesh.new()
		mesh.mesh.size = Vector3(.01, .01, .01)
		node.add_child(mesh)
		node.add_child(collision_shape)
		joints_storage.add_child(node)
		joints.append(node)
		node.global_position = anchor.global_position + i * (hand_body.global_position - anchor.global_position) / points.size() + Vector3.UP*.1

func _physics_process(delta: float) -> void:
	# Raycasting
	var ray_query = PhysicsRayQueryParameters3D.new()
	var mouse_pos = get_viewport().get_mouse_position()
	ray_query.from = camera.project_ray_origin(mouse_pos)
	ray_query.to = ray_query.from + camera.project_ray_normal(mouse_pos) * 100
	ray_query.collision_mask = 1

	var results = camera.get_world_3d().direct_space_state.intersect_ray(ray_query)

	pointed_direction = (ray_query.from - ray_query.to).normalized()
	if results:
		pointed_location = results.position
		# if results.collider.is_in_group("grabbable_cards"): TODO Maybe do smthg for snapping
	else:
		pointed_location = ray_query.from - pointed_direction * dist_out
	
	# Move
	hand_body.velocity = (pointed_location - hand_body.global_position) * 1000 * delta
	hand_body.global_position = pointed_location
	#hand_body.move_and_slide()
		#var collision_info = hand_body.get_last_slide_collision()
		#var norm = collision_info.get_normal()
		#var dst = collision_info.get_position().length()
		#var normal_plane = Plane(norm, dst)
		#var target = Geometry3D.plane_intersects_line(
			#normal_plane, pointed_location, slide_dir,
		#)
		#hand_body.velocity = (target - finger_tip.global_position) * 500 * delta
		#hand_body.move_and_slide()

	# Adjust arm length
	var required_length = (anchor.global_position - hand_body.position).length()
	if required_length / arm.points.size() > distance_constraint: # Too short, emergency fix
		distance_constraint = required_length / arm.points.size()
	elif required_length / (arm.points.size() - 2) < distance_constraint: # Too long, spool back slowly
		distance_constraint -= delta * reactivity
	#if distance_constraint < required_length / (arm.points.size() - 1): # Long enough but may be longer, grow slowly
		#distance_constraint += delta * reactivity

	# Run FABRIK
	FABRIK_pass(delta)


# gdlint:ignore = function-name
func FABRIK_pass(delta: float):
	# Backward
	joints[0].global_position = anchor.global_position # Set the last node to the target position
	for i in range(1, joints.size()):
		var new_direction = (joints[i].position - joints[i - 1].position).normalized()
		joints[i].velocity = (
			joint_speed
			* delta
			* ((joints[i - 1].position + new_direction * distance_constraint) - joints[i].global_position)
		)
		joints[i].move_and_slide()

	# Forward
	joints[joints.size() - 1].global_position = hand_body.global_position # Set the first node to the anchor position
	for i in range(joints.size() - 2, -1, -1):
		var new_direction = (joints[i + 1].position - joints[i].position).normalized()
		joints[i].velocity = (
			joint_speed
			* delta
			* ((joints[i + 1].position - new_direction * distance_constraint) - joints[i].global_position)
		)
		joints[i].move_and_slide()

	var points = []
	for i in range(joints.size()):
		points.append(camera.unproject_position(joints[i].global_position))
	arm.set_points(points)

	#hand_body.global_rotation = points[points.size() - 2].angle_to_point(points[points.size() - 1])
