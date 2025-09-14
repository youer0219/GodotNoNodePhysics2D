# ============================================================================
#  QuickAreaInstance.gd
# ---------------------------------------------------------------------------
#  轻量级 2D 区域实例，直接操作 PhysicsServer2D，
#  支持进入/离开信号、引用计数、树生命周期管理。
# ============================================================================
class_name QuickAreaInstance
extends Instance2D

# ------------------------------------------------------------------
#  对外信号
# ------------------------------------------------------------------
signal area_entered(area: Area2D, other_area_rid: RID, self_area_rid: RID)
signal area_exited(area: Area2D, other_area_rid: RID, self_area_rid: RID)
signal body_entered(body: Node, body_rid: RID, area_rid: RID)
signal body_exited(body: Node, body_rid: RID, area_rid: RID)

# ------------------------------------------------------------------
#  核心句柄与数据
# ------------------------------------------------------------------
var area_rid: RID
var shape_rid: RID
var data: QuickAreaData
var owner_weakref: WeakRef

# ------------------------------------------------------------------
#  监控属性
# ------------------------------------------------------------------
var monitoring: bool = true:
	set(v):
		monitoring = v
		_update_monitoring()

var monitorable: bool = true:
	set(v):
		monitorable = v
		_update_monitorable()

# ------------------------------------------------------------------
#  进入记录（RID -> State）
# ------------------------------------------------------------------
var body_map: Dictionary = {}  # body_rid  : BodyState
var area_map: Dictionary = {}  # area_rid  : AreaState

class BodyState:
	var node: WeakRef
	var rc: int      = 0
	var in_tree: bool = false

class AreaState:
	var node: WeakRef
	var rc: int      = 0
	var in_tree: bool = false

# ==============================================================================
#  构造 / 初始化
# ==============================================================================
func _init(area_data: QuickAreaData, area_owner: Object, area_transform: Transform2D, space: RID) -> void:
	area_rid = PhysicsServer2D.area_create()
	setup(area_data, area_owner, area_transform, space)

func setup(area_data: QuickAreaData, area_owner: Object, area_transform: Transform2D, space: RID) -> void:
	data            = area_data
	owner_weakref   = weakref(area_owner)
	transform       = area_transform
	monitoring      = data.monitoring
	monitorable     = data.monitorable

	_create_area_shape(data)
	PhysicsServer2D.area_add_shape(area_rid, shape_rid)
	PhysicsServer2D.area_set_space(area_rid, space)
	PhysicsServer2D.area_set_collision_layer(area_rid, data.collision_layer)
	PhysicsServer2D.area_set_collision_mask(area_rid, data.collision_mask)

# ==============================================================================
#  所有者访问
# ==============================================================================
func get_owner() -> Object:
	return owner_weakref.get_ref() if owner_weakref else null

# ==============================================================================
#  对外查询接口
# ==============================================================================
func get_overlapping_areas() -> Array:
	if not monitoring:
		push_warning("Can't query overlapping areas when monitoring is off.")
		return []
	var ret := []
	for s in area_map.values():
		var n = s.node.get_ref()
		if n and n is Node and s.in_tree:
			ret.append(n)
	return ret

func get_overlapping_bodies() -> Array:
	if not monitoring:
		push_warning("Can't query overlapping bodies when monitoring is off.")
		return []
	var ret := []
	for s in body_map.values():
		var n = s.node.get_ref()
		if n and n is Node and s.in_tree:
			ret.append(n)
	return ret

func has_overlapping_areas() -> bool:
	if not monitoring:
		push_warning("Can't query overlapping areas when monitoring is off.")
		return false
	return area_map.values().any(func(s): return s.in_tree)

func has_overlapping_bodies() -> bool:
	if not monitoring:
		push_warning("Can't query overlapping bodies when monitoring is off.")
		return false
	return body_map.values().any(func(s): return s.in_tree)

func overlaps_area(area: Node) -> bool:
	if not monitoring:
		push_warning("Can't check overlaps when monitoring is off.")
		return false
	if not area: return false
	for s in area_map.values():
		var n = s.node.get_ref()
		if n == area and s.in_tree:
			return true
	return false

func overlaps_body(body: Node) -> bool:
	if not monitoring:
		push_warning("Can't check overlaps when monitoring is off.")
		return false
	if not body: return false
	for s in body_map.values():
		var n = s.node.get_ref()
		if n == body and s.in_tree:
			return true
	return false

# ==============================================================================
#  空间 / 形状 / 层掩码
# ==============================================================================
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

# ==============================================================================
#  监控开关
# ==============================================================================
func _update_monitorable() -> void:
	PhysicsServer2D.area_set_monitorable(area_rid, monitorable)

func _update_monitoring() -> void:
	if monitoring:
		PhysicsServer2D.area_set_monitor_callback(area_rid, _on_body_monitor_callback)
		PhysicsServer2D.area_set_area_monitor_callback(area_rid, _on_area_monitor_callback)
	else:
		PhysicsServer2D.area_set_monitor_callback(area_rid, Callable())
		PhysicsServer2D.area_set_area_monitor_callback(area_rid, Callable())
		clear_monitoring()

# ==============================================================================
#  树生命周期钩子（手动绑定）
# ==============================================================================
func _area_enter_tree(other_area_rid: RID) -> void:
	var state := area_map.get(other_area_rid)
	if not state: return
	var area = state.node.get_ref()
	if area and not state.in_tree:
		state.in_tree = true
		emit_signal("area_entered", area, other_area_rid, area_rid)

func _area_exit_tree(other_area_rid: RID) -> void:
	var state := area_map.get(other_area_rid)
	if not state: return
	var area = state.node.get_ref()
	if area and state.in_tree:
		state.in_tree = false
		emit_signal("area_exited", area, other_area_rid, area_rid)

func _body_enter_tree(body_rid: RID) -> void:
	var state := body_map.get(body_rid)
	if not state: return
	var body = state.node.get_ref()
	if body and not state.in_tree:
		state.in_tree = true
		emit_signal("body_entered", body, body_rid, area_rid)

func _body_exit_tree(body_rid: RID) -> void:
	var state := body_map.get(body_rid)
	if not state: return
	var body = state.node.get_ref()
	if body and state.in_tree:
		state.in_tree = false
		emit_signal("body_exited", body, body_rid, area_rid)

# ==============================================================================
#  PhysicsServer 回调
# ==============================================================================
func _on_area_monitor_callback(
		status: int,
		other_area_rid: RID,
		other_instance_id: int,
		_area_shape: int,
		_self_shape: int
) -> void:
	var other_obj  = instance_from_id(other_instance_id)
	var entering   = status == PhysicsServer2D.AREA_BODY_ADDED

	if not is_instance_valid(other_obj):
		emit_signal("area_" + ("entered" if entering else "exited"), null, other_area_rid, area_rid)
		return

	if entering:
		if not area_map.has(other_area_rid):
			var st        = AreaState.new()
			st.node       = weakref(other_obj)
			st.in_tree    = other_obj.is_inside_tree()
			area_map[other_area_rid] = st

			if st.in_tree and other_instance_id != GlobalAreaManager.get_instance_id():
				other_obj.connect("tree_entered", Callable(self, "_area_enter_tree").bind(other_area_rid))
				other_obj.connect("tree_exiting", Callable(self, "_area_exit_tree").bind(other_area_rid))

			if st.in_tree:
				emit_signal("area_entered", other_obj, other_area_rid, area_rid)
		area_map[other_area_rid].rc += 1
	else:
		if area_map.has(other_area_rid):
			var st = area_map[other_area_rid]
			st.rc -= 1
			if st.rc == 0:
				if other_instance_id != GlobalAreaManager.get_instance_id():
					if other_obj.is_connected("tree_entered", Callable(self, "_area_enter_tree")):
						other_obj.disconnect("tree_entered", Callable(self, "_area_enter_tree"))
					if other_obj.is_connected("tree_exiting", Callable(self, "_area_exit_tree")):
						other_obj.disconnect("tree_exiting", Callable(self, "_area_exit_tree"))
				if st.in_tree:
					emit_signal("area_exited", other_obj, other_area_rid, area_rid)
				area_map.erase(other_area_rid)

func _on_body_monitor_callback(
		status: int,
		body_rid: RID,
		body_instance_id: int,
		_body_shape: int,
		_self_shape: int
) -> void:
	var body_obj  = instance_from_id(body_instance_id)
	var entering  = status == PhysicsServer2D.AREA_BODY_ADDED

	if not is_instance_valid(body_obj):
		emit_signal("body_" + ("entered" if entering else "exited"), null, body_rid, area_rid)
		return

	if entering:
		if not body_map.has(body_rid):
			var st     = BodyState.new()
			st.node    = weakref(body_obj)
			st.in_tree = body_obj.is_inside_tree()
			body_map[body_rid] = st

			if st.in_tree:
				body_obj.connect("tree_entered", Callable(self, "_body_enter_tree").bind(body_rid))
				body_obj.connect("tree_exiting", Callable(self, "_body_exit_tree").bind(body_rid))

			if st.in_tree:
				emit_signal("body_entered", body_obj, body_rid, area_rid)
		body_map[body_rid].rc += 1
	else:
		if body_map.has(body_rid):
			var st = body_map[body_rid]
			st.rc -= 1
			if st.rc == 0:
				# 完全离开
				if body_obj.is_connected("tree_entered", Callable(self, "_body_enter_tree")):
					body_obj.disconnect("tree_entered", Callable(self, "_body_enter_tree"))
				if body_obj.is_connected("tree_exiting", Callable(self, "_body_exit_tree")):
					body_obj.disconnect("tree_exiting", Callable(self, "_body_exit_tree"))
				if st.in_tree:
					emit_signal("body_exited", body_obj, body_rid, area_rid)
				body_map.erase(body_rid)

# ==============================================================================
#  工具：形状创建
# ==============================================================================
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

# ==============================================================================
#  清理 / 回池 / 销毁
# ==============================================================================
func clear_for_pool() -> void:
	data        = null
	owner_weakref = null
	transform   = Transform2D()
	monitorable = false
	monitoring  = false
	PhysicsServer2D.area_clear_shapes(area_rid)
	PhysicsServer2D.area_set_collision_layer(area_rid, 0)
	PhysicsServer2D.area_set_collision_mask(area_rid, 0)
	if shape_rid.is_valid():
		PhysicsServer2D.free_rid(shape_rid)
		shape_rid = RID()

func clear_monitoring() -> void:
	# 断开所有树信号并补发 exit
	for body_rid in body_map.keys():
		var st  = body_map[body_rid]
		var body = st.node.get_ref() if st.node else null
		if body:
			for sig in ["tree_entered", "tree_exiting"]:
				if body.is_connected(sig, Callable(self, "_body_" + sig.left(5) + "_tree")):
					body.disconnect(sig, Callable(self, "_body_" + sig.left(5) + "_tree"))
		if body and body.is_inside_tree() and st.in_tree:
			emit_signal("body_exited", body, body_rid, area_rid)

	for area_rid_k in area_map.keys():
		var st  = area_map[area_rid_k]
		var area = st.node.get_ref() if st.node else null
		if area:
			for sig in ["tree_entered", "tree_exiting"]:
				if area.is_connected(sig, Callable(self, "_area_" + sig.left(5) + "_tree")):
					area.disconnect(sig, Callable(self, "_area_" + sig.left(5) + "_tree"))
		if area and area.is_inside_tree() and st.in_tree:
			emit_signal("area_exited", area, area_rid_k, area_rid)

	body_map.clear()
	area_map.clear()

func free_rids() -> void:
	if shape_rid.is_valid():
		PhysicsServer2D.free_rid(shape_rid)
		shape_rid = RID()
	if area_rid.is_valid():
		PhysicsServer2D.free_rid(area_rid)
		area_rid = RID()
