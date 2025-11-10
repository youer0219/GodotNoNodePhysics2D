# global_area_manager.gd
extends Node2D

var space: RID

func _ready() -> void:
	space = get_world_2d().space

# 创建新的AreaInstance
func create_area(area_data: QuickAreaData, area_owner: Object, area_transform: Transform2D = Transform2D()) -> QuickAreaInstance:
	return QuickAreaInstance.new(area_data, area_owner, area_transform, space)

func get_instance_by_rid(rid:RID)->QuickAreaInstance:
	var id = PhysicsServer2D.area_get_object_instance_id(rid)
	var instance := instance_from_id(id)
	return instance
