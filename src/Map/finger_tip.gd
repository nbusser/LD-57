extends Node2D

const CARD_LAYER = 7

var distance = .5

@onready var camera = get_node_or_null("../../../../CameraRail/FollowRail/Camera")
@onready var enemy = get_node_or_null("../../../../Enemy")
@onready var left_eye = get_node_or_null("../../../../Enemy/LeftEye")
@onready var right_eye = get_node_or_null("../../../../Enemy/RightEye")
@onready var camera_menu = get_node_or_null("../../../../Camera3D")

# Finger tip is now the same as HandBody's position, making this relatively
# useless


func _physics_process(_delta: float) -> void:
	if !camera && !camera_menu:
		return

	if camera:
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = camera.project_ray_origin(global_position)
		ray_query.to = ray_query.from + camera.project_ray_normal(global_position) * 1000
		var results = camera.get_world_3d().direct_space_state.intersect_ray(ray_query)
		if results:
			distance = (results.position - camera.global_position).length()
		else:
			distance = .5

	else:
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = camera_menu.project_ray_origin(global_position)
		ray_query.to = ray_query.from + camera_menu.project_ray_normal(global_position) * 1000
		var results = camera_menu.get_world_3d().direct_space_state.intersect_ray(ray_query)
		if results:
			distance = (results.position - camera_menu.global_position).length()
		else:
			distance = .5


func _input(event):
	if !camera:
		return

	if (
		event is InputEventMouseButton
		and event.is_pressed()
		and event.button_index == MOUSE_BUTTON_LEFT
	):
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = camera.project_ray_origin(global_position)
		ray_query.to = ray_query.from + camera.project_ray_normal(global_position) * 1000
		var results = camera.get_world_3d().direct_space_state.intersect_ray(ray_query)

		if results && results.collider == left_eye:
			enemy.poke_left()
		elif results && results.collider == right_eye:
			enemy.poke_right()


func get_closest_card() -> Card:
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = camera.project_ray_origin(global_position)
	ray_query.to = ray_query.from + camera.project_ray_normal(global_position) * 100
	ray_query.collision_mask = 1 << CARD_LAYER - 1
	var results = camera.get_world_3d().direct_space_state.intersect_ray(ray_query)

	if results && results.collider.is_in_group("grabbable_cards"):
		return results.collider
	return null
