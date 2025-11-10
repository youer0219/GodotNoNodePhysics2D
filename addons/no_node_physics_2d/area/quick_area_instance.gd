# ============================================================================
#  QuickAreaInstance.gd
# ---------------------------------------------------------------------------
#  轻量级 2D 区域实例，直接操作 PhysicsServer2D，
#  仅能被检测，不能检测其他区域或实体。
# ============================================================================
class_name QuickAreaInstance
extends Instance2D

#region 核心句柄与数据
var area_rid: RID
var shape_rid: RID
var data: QuickAreaData
var owner_weakref: WeakRef
#endregion

#region 监控属性
var monitorable: bool = true:
	set(v):
		monitorable = v
		_update_monitorable()
#endregion

#region 构造 / 初始化 / 销毁
func _init(area_data: QuickAreaData, area_owner: Object, area_transform: Transform2D, space: RID) -> void:
	area_rid = PhysicsServer2D.area_create()
	setup(area_data, area_owner, area_transform, space)
	# 注册到全局管理器
	if GlobalAreaManager:
		GlobalAreaManager.register_instance(self)

func setup(area_data: QuickAreaData, area_owner: Object, area_transform: Transform2D, space: RID) -> void:
	data            = area_data
	owner_weakref   = weakref(area_owner)
	transform       = area_transform
	monitorable     = data.monitorable

	_create_area_shape(data)
	PhysicsServer2D.area_add_shape(area_rid, shape_rid)
	PhysicsServer2D.area_set_space(area_rid, space)
	PhysicsServer2D.area_set_collision_layer(area_rid, data.collision_layer)
	PhysicsServer2D.area_set_collision_mask(area_rid, 0) ## 禁止检测其他区域或物体
	PhysicsServer2D.area_set_monitorable(area_rid, monitorable)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		# 从全局管理器注销
		GlobalAreaManager.unregister_instance(area_rid)
		if shape_rid.is_valid():
			PhysicsServer2D.free_rid(shape_rid)
			shape_rid = RID()
		if area_rid.is_valid():
			PhysicsServer2D.free_rid(area_rid)
			area_rid = RID()
#endregion

#region 所有者访问
func get_owner() -> Object:
	return owner_weakref.get_ref() if owner_weakref else null
#endregion

#region 空间 / 形状 / 层掩码
func set_collision_layer(layer: int) -> void:
	PhysicsServer2D.area_set_collision_layer(area_rid, layer)

func set_collision_mask(mask: int) -> void:
	PhysicsServer2D.area_set_collision_mask(area_rid, mask)

func set_shape_disabled(shape_idx: int, disabled: bool) -> void:
	PhysicsServer2D.area_set_shape_disabled(area_rid, shape_idx, disabled)

func set_shape_transform(shape_idx: int, shape_transform: Transform2D) -> void:
	PhysicsServer2D.area_set_shape_transform(area_rid, shape_idx, shape_transform)

func set_space(space: RID) -> void:
	PhysicsServer2D.area_set_space(area_rid, space)

func set_transform(new_transform: Transform2D) -> void:
	super(new_transform)
	PhysicsServer2D.area_set_transform(area_rid, transform)
#endregion

#region 监控管理
func _update_monitorable() -> void:
	PhysicsServer2D.area_set_monitorable(area_rid, monitorable)
#endregion

#region 形状工具
func _create_area_shape(new_area_data: QuickAreaData) -> void:
	var sr = new_area_data.shape_resource
	match typeof(sr):
		TYPE_OBJECT:
			if sr is CircleShape2D:
				shape_rid = PhysicsServer2D.circle_shape_create()
				PhysicsServer2D.shape_set_data(shape_rid, sr.radius)
			elif sr is RectangleShape2D:
				shape_rid = PhysicsServer2D.rectangle_shape_create()
				PhysicsServer2D.shape_set_data(shape_rid, sr.size * 0.5)
			elif sr is CapsuleShape2D:
				shape_rid = PhysicsServer2D.capsule_shape_create()
				PhysicsServer2D.shape_set_data(shape_rid, Vector2(sr.radius, sr.height))
			elif sr is ConvexPolygonShape2D:
				shape_rid = PhysicsServer2D.convex_polygon_shape_create()
				PhysicsServer2D.shape_set_data(shape_rid, sr.points)
			elif sr is ConcavePolygonShape2D:
				shape_rid = PhysicsServer2D.concave_polygon_shape_create()
				PhysicsServer2D.shape_set_data(shape_rid, sr.segments)
			else:
				push_error("Unsupported shape type: " + sr.get_class())
		TYPE_NIL:
			push_error("QuickAreaData.shape_resource is null!")
		_:
			push_error("Unknown shape_resource type!")
#endregion
