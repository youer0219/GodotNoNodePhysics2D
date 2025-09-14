# AreaData 作为资源，存储共享属性
class_name AreaData
extends Resource

@export var shape_resource: Shape2D
@export_flags_2d_physics var collision_layer: int = 1
@export_flags_2d_physics var collision_mask: int = 1
@export var monitoring: bool = true
@export var monitorable: bool = true
