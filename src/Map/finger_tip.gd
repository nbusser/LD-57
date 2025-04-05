extends Node2D

@onready var camera = get_node("../../../../CameraRail/FollowRail/Camera")

func get_closest_card():
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = camera.project_ray_origin(global_position)
	ray_query.to = ray_query.from + camera.project_ray_normal(global_position)*100
	var results = camera.get_world_3d().direct_space_state.intersect_ray(ray_query)
	
	var closest_card = null
	var closest_distance = INF
	
	if results && results.collider.is_in_group("cards"):
		return results.collider
	return null
