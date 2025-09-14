extends Node2D

var quick_ray_cast_instance:QuickRayCastInstance

func _ready() -> void:
	quick_ray_cast_instance = QuickRayCastInstance.new()
	quick_ray_cast_instance.collide_with_areas = true
	quick_ray_cast_instance.collide_with_bodies = true
	quick_ray_cast_instance.collision_mask = 1
	quick_ray_cast_instance.hit_from_inside = true
	quick_ray_cast_instance.target_position = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	if get_tree().get_frame() % 30 == 0:
		cast()
		$RayCast2D.force_raycast_update()
		print($RayCast2D.get_collider())

func cast():
	var query =  PhysicsRayQueryParameters2D.new()
	query.collide_with_areas = quick_ray_cast_instance.collide_with_areas
	query.collide_with_bodies = quick_ray_cast_instance.collide_with_bodies
	query.collision_mask = quick_ray_cast_instance.collision_mask
	query.hit_from_inside = quick_ray_cast_instance.hit_from_inside
	query.from = quick_ray_cast_instance.position
	query.to = quick_ray_cast_instance.position + quick_ray_cast_instance.target_position
	var result = PhysicsServer2D.space_get_direct_state(get_world_2d().space).intersect_ray(query)
	print(result)
