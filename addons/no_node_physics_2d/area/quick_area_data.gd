# quick_area_data.gd
class_name QuickAreaData
extends Resource

@export var shape_resource: Shape2D
@export_flags_2d_physics var collision_layer: int = 1
@export var monitorable: bool = true
