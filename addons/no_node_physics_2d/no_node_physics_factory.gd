# ============================================================================
#  no_node_physics_factory.gd
# ---------------------------------------------------------------------------
#  物理实体工厂，负责创建 Area2D、RayCast2D、ShapeCast2D 等非节点物理实例
#  作为自动加载单例使用，实例自行管理生命周期
# ============================================================================
#class_name NoNodePhysicsFactory
extends Node2D

var space: RID

func _ready() -> void:
	space = get_world_2d().space

#region Area2D 工厂方法
# 创建新的 AreaInstance
func create_area(area_data: QuickAreaData, area_owner: Object, area_transform: Transform2D = Transform2D()) -> QuickAreaInstance:
	return QuickAreaInstance.new(area_data, area_owner, area_transform, space)

# 根据 RID 获取 AreaInstance
func get_area_instance_by_rid(rid: RID) -> QuickAreaInstance:
	var id = PhysicsServer2D.area_get_object_instance_id(rid)
	var instance = instance_from_id(id)
	return instance as QuickAreaInstance
#endregion

#region 未来 Cast 工厂方法（预留）

#endregion
