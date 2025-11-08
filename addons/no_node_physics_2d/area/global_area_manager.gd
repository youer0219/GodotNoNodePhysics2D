# GlobalAreaManager.gd
extends Node2D

var instances: Dictionary = {}  # RID -> QuickAreaInstance
var space: RID

func _ready() -> void:
	space = get_world_2d().space

# 注册AreaInstance
func register_instance(instance: QuickAreaInstance) -> void:
	instances[instance.area_rid] = instance

# 注销AreaInstance
func unregister_instance(area_rid: RID) -> void:
	instances.erase(area_rid)

# 创建新的AreaInstance
func create_area(area_data: QuickAreaData, area_owner: Object, area_transform: Transform2D = Transform2D()) -> QuickAreaInstance:
	return QuickAreaInstance.new(area_data, area_owner, area_transform, space)

# 根据RID获取AreaInstance的所有者
func get_area_owner(area_rid: RID) -> Object:
	var instance = instances.get(area_rid)
	return instance.get_owner() if instance else null

# 根据RID获取AreaInstance
func get_area_instance(area_rid: RID) -> QuickAreaInstance:
	return instances.get(area_rid)

# 设置AreaInstance的变换
func set_area_transform(area_rid: RID, xform: Transform2D) -> void:
	var instance = instances.get(area_rid)
	if instance:
		instance.set_transform(xform)

# 获取所有活跃的AreaInstance数量（调试用）
func get_active_instance_count() -> int:
	return instances.size()

# 清理所有实例（主要用于场景切换）
func clear_all_instances() -> void:
	for instance in instances.values():
		instance.free_rids()
	instances.clear()
