# area_2d_instance_data.gd
class_name Area2DInstanceData
extends Resource

@export var shape_resource: Shape2D
@export_flags_2d_physics var collision_layer: int = 1
@export var monitorable: bool = true
