# AreaInstance 管理实时数据信号
class_name AreaInstance
extends Instance2D

signal body_entered(body: Node, body_rid: RID, area_rid: RID)
signal body_exited(body: Node, body_rid: RID, area_rid: RID)
signal area_entered(area: Node, other_area_rid: RID, self_area_rid: RID)
signal area_exited(area: Node, other_area_rid: RID, self_area_rid: RID)

var area_rid: RID
var data: AreaData
var shape_rid: RID 
var owner_weakref: WeakRef

func set_transform(new_transform:Transform2D):
	super(new_transform)
	PhysicsServer2D.area_set_transform(area_rid, transform)

# 设置碰撞层
func set_collision_layer(layer: int) -> void:
	PhysicsServer2D.area_set_collision_layer(area_rid, layer)

# 设置碰撞掩码
func set_collision_mask(mask: int) -> void:
	PhysicsServer2D.area_set_collision_mask(area_rid, mask)

# 设置区域所在的空间
func set_space(space: RID) -> void:
	PhysicsServer2D.area_set_space(area_rid, space)

# 设置形状的变换
func set_shape_transform(shape_idx: int, shape_transform: Transform2D) -> void:
	PhysicsServer2D.area_set_shape_transform(area_rid, shape_idx, shape_transform)

# 设置形状是否禁用
func set_shape_disabled(shape_idx: int, disabled: bool) -> void:
	PhysicsServer2D.area_set_shape_disabled(area_rid, shape_idx, disabled)

# 监控属性
var monitoring: bool = true:
	set(value):
		monitoring = value
		_update_monitoring()

var monitorable: bool = true:
	set(value):
		monitorable = value
		_update_monitorable()

# 记录进入的物体和区域 (使用 RID 作为键)
var body_map: Dictionary = {}  # body_rid -> BodyState
var area_map: Dictionary = {}  # area_rid -> AreaState

class BodyState:
	var node: WeakRef  # 弱引用，避免循环引用
	var rc: int = 0    # 引用计数
	var in_tree: bool = false

class AreaState:
	var node: WeakRef  # 弱引用，避免循环引用
	var rc: int = 0    # 引用计数
	var in_tree: bool = false

func _init(area_data: AreaData, area_owner: Object, area_transform: Transform2D, space:RID):
	area_rid = PhysicsServer2D.area_create()
	setup(area_data,area_owner,area_transform,space)

func setup(area_data: AreaData, area_owner: Object, area_transform: Transform2D, space: RID) -> void:
	data = area_data
	owner_weakref = weakref(area_owner)
	transform = area_transform
	
	monitoring = data.monitoring
	monitorable = data.monitorable
	
	_create_area_shape(data)
	
	PhysicsServer2D.area_add_shape(area_rid, shape_rid)
	PhysicsServer2D.area_set_space(area_rid, space)
	PhysicsServer2D.area_set_collision_layer(area_rid, data.collision_layer)
	PhysicsServer2D.area_set_collision_mask(area_rid, data.collision_mask)

func get_owner()->Object:
	return owner_weakref.get_ref()

func clear_for_pool():
	data = null
	owner_weakref = null
	transform = Transform2D()
	monitorable = false
	monitoring = false
	PhysicsServer2D.area_clear_shapes(area_rid)
	PhysicsServer2D.area_set_collision_layer(area_rid, 0)
	PhysicsServer2D.area_set_collision_mask(area_rid, 0)
	
	if shape_rid.is_valid():
		PhysicsServer2D.free_rid(shape_rid)
		shape_rid = RID()

func clear_monitoring() -> void:
	# 清理所有物体：断开连接并发射信号
	for body_rid in body_map.keys():
		var state = body_map[body_rid]
		var body = state.node.get_ref() if state.node else null
		if body:
			# 断开信号连接
			if body.is_connected("tree_entered", Callable(self, "_body_enter_tree")):
				body.disconnect("tree_entered", Callable(self, "_body_enter_tree"))
			if body.is_connected("tree_exiting", Callable(self, "_body_exit_tree")):
				body.disconnect("tree_exiting", Callable(self, "_body_exit_tree"))
		if body and body.is_inside_tree() and state.in_tree:
			emit_signal("body_exited", body, body_rid, area_rid)
	
	# 清理所有区域：断开连接并发射信号
	for other_area_rid in area_map.keys():
		var state = area_map[other_area_rid]
		var area = state.node.get_ref() if state.node else null
		if area:
			# 断开信号连接
			if area.is_connected("tree_entered", Callable(self, "_area_enter_tree")):
				area.disconnect("tree_entered", Callable(self, "_area_enter_tree"))
			if area.is_connected("tree_exiting", Callable(self, "_area_exit_tree")):
				area.disconnect("tree_exiting", Callable(self, "_area_exit_tree"))
		if area and area.is_inside_tree() and state.in_tree:
			emit_signal("area_exited", area, other_area_rid, area_rid)
	
	body_map.clear()
	area_map.clear()

func free_rids() -> void:
	if shape_rid.is_valid():
		PhysicsServer2D.free_rid(shape_rid)
		shape_rid = RID()
	if area_rid.is_valid():
		PhysicsServer2D.free_rid(area_rid)
		area_rid = RID()

func _body_enter_tree(body_rid: RID) -> void:
	if not body_map.has(body_rid):
		return
		
	var state = body_map[body_rid]
	var body = state.node.get_ref() if state.node else null
	
	if body and not state.in_tree:
		state.in_tree = true
		emit_signal("body_entered", body, body_rid, area_rid)

func _body_exit_tree(body_rid: RID) -> void:
	if not body_map.has(body_rid):
		return
		
	var state = body_map[body_rid]
	var body = state.node.get_ref() if state.node else null
	
	if body and state.in_tree:
		state.in_tree = false
		emit_signal("body_exited", body, body_rid, area_rid)

func _area_enter_tree(other_area_rid: RID) -> void:
	if not area_map.has(other_area_rid):
		return
		
	var state = area_map[other_area_rid]
	var area = state.node.get_ref() if state.node else null
	
	if area and not state.in_tree:
		state.in_tree = true
		emit_signal("area_entered", area, other_area_rid, area_rid)

func _area_exit_tree(other_area_rid: RID) -> void:
	if not area_map.has(other_area_rid):
		return
		
	var state = area_map[other_area_rid]
	var area = state.node.get_ref() if state.node else null
	
	if area and state.in_tree:
		state.in_tree = false
		emit_signal("area_exited", area, other_area_rid, area_rid)

# 更新监控状态
func _update_monitoring() -> void:
	if not monitoring:
		PhysicsServer2D.area_set_area_monitor_callback(area_rid,Callable())
		PhysicsServer2D.area_set_monitor_callback(area_rid,Callable())
		clear_monitoring()
	else:
		PhysicsServer2D.area_set_area_monitor_callback(area_rid,_on_area_monitor_callback)
		PhysicsServer2D.area_set_monitor_callback(area_rid,_on_body_monitor_callback)

# 更新可被监控状态
func _update_monitorable() -> void:
	PhysicsServer2D.area_set_monitorable(area_rid, monitorable)

# 获取重叠区域和物体
func get_overlapping_bodies() -> Array:
	if not monitoring:
		push_warning("Can't find overlapping bodies when monitoring is off.")
		return []
		
	var result = []
	for state in body_map.values():
		var body = state.node.get_ref() if state.node else null
		if body and body is Node and state.in_tree:
			result.append(body)
	return result

func get_overlapping_areas() -> Array:
	if not monitoring:
		push_warning("Can't find overlapping areas when monitoring is off.")
		return []
		
	var result = []
	for state in area_map.values():
		var area = state.node.get_ref() if state.node else null
		if area and area is Node and state.in_tree:
			result.append(area)
	return result

func has_overlapping_bodies() -> bool:
	if not monitoring:
		push_warning("Can't find overlapping bodies when monitoring is off.")
		return false
		
	for state in body_map.values():
		if state.in_tree:
			return true
	return false

func has_overlapping_areas() -> bool:
	if not monitoring:
		push_warning("Can't find overlapping areas when monitoring is off.")
		return false
		
	for state in area_map.values():
		if state.in_tree:
			return true
	return false

func overlaps_body(body: Node) -> bool:
	if not monitoring:
		push_warning("Can't check overlaps when monitoring is off.")
		return false
		
	if not body:
		return false
		
	for state in body_map.values():
		var body_ref = state.node.get_ref() if state.node else null
		if body_ref == body and state.in_tree:
			return true
	return false

func overlaps_area(area: Node) -> bool:
	if not monitoring:
		push_warning("Can't check overlaps when monitoring is off.")
		return false
		
	if not area:
		return false
		
	for state in area_map.values():
		var area_ref = state.node.get_ref() if state.node else null
		if area_ref == area and state.in_tree:
			return true
	return false

# 区域监控回调
func _on_area_monitor_callback(
	status: int,
	other_area_rid: RID,
	other_instance_id: int,
	_area_shape_idx: int,
	_self_shape_idx: int,
) -> void:
	# 获取其他对象
	var other_obj = instance_from_id(other_instance_id)
	
	# 处理进入/离开事件
	var area_in = status == PhysicsServer2D.AREA_BODY_ADDED
	
	# 检查对象有效性
	if not is_instance_valid(other_obj):
		if area_in:
			emit_signal("area_entered", null, other_area_rid, area_rid)
		else:
			emit_signal("area_exited", null, other_area_rid, area_rid)
		return
	
	if area_in:
		if not area_map.has(other_area_rid):
			# 首次进入
			var state = AreaState.new()
			state.node = weakref(other_obj)
			state.in_tree = other_obj.is_inside_tree()
			area_map[other_area_rid] = state
			
			# 连接树信号 
			if other_obj.is_inside_tree() and other_instance_id != GlobalAreaManager.get_instance_id():
				other_obj.connect("tree_entered", Callable(self, "_area_enter_tree").bind(other_area_rid))
				other_obj.connect("tree_exiting", Callable(self, "_area_exit_tree").bind(other_area_rid))
			
			if state.in_tree:
				emit_signal("area_entered", other_obj, other_area_rid, area_rid)
		
		# 增加引用计数
		area_map[other_area_rid].rc += 1
	else:
		if area_map.has(other_area_rid):
			var state = area_map[other_area_rid]
			state.rc -= 1
			
			if state.rc == 0:
				# 完全离开
				if other_instance_id != GlobalAreaManager.get_instance_id():
					if other_obj.is_connected("tree_entered", Callable(self, "_area_enter_tree")):
						other_obj.disconnect("tree_entered", Callable(self, "_area_enter_tree"))
					if other_obj.is_connected("tree_exiting", Callable(self, "_area_exit_tree")):
						other_obj.disconnect("tree_exiting", Callable(self, "_area_exit_tree"))
				
				if state.in_tree:
					emit_signal("area_exited", other_obj, other_area_rid, area_rid)
				
				area_map.erase(other_area_rid)

# 物体监控回调
func _on_body_monitor_callback(
	status: int,
	body_rid: RID,
	body_instance_id: int,
	_body_shape_idx: int,
	_self_shape_idx: int,
) -> void:
	# 获取其他对象
	var body_obj = instance_from_id(body_instance_id)
	
	# 处理进入/离开事件
	var body_in = status == PhysicsServer2D.AREA_BODY_ADDED
	
	# 检查对象有效性
	if not is_instance_valid(body_obj):
		if body_in:
			emit_signal("body_entered", null, body_rid, area_rid)
		else:
			emit_signal("body_exited", null, body_rid, area_rid)
		return
	
	if body_in:
		if not body_map.has(body_rid):
			# 首次进入
			var state = BodyState.new()
			state.node = weakref(body_obj)
			state.in_tree = body_obj.is_inside_tree()
			body_map[body_rid] = state
			
			# 连接树信号
			if body_obj.is_inside_tree():
				body_obj.connect("tree_entered", Callable(self, "_body_enter_tree").bind(body_rid))
				body_obj.connect("tree_exiting", Callable(self, "_body_exit_tree").bind(body_rid))
			
			if state.in_tree:
				emit_signal("body_entered", body_obj, body_rid, area_rid)
		
		# 增加引用计数
		body_map[body_rid].rc += 1
	else:
		if body_map.has(body_rid):
			var state = body_map[body_rid]
			state.rc -= 1
			
			if state.rc == 0:
				# 完全离开
				if body_obj.is_connected("tree_entered", Callable(self, "_body_enter_tree")):
					body_obj.disconnect("tree_entered", Callable(self, "_body_enter_tree"))
				if body_obj.is_connected("tree_exiting", Callable(self, "_body_exit_tree")):
					body_obj.disconnect("tree_exiting", Callable(self, "_body_exit_tree"))
				
				if state.in_tree:
					emit_signal("body_exited", body_obj, body_rid, area_rid)
				
				body_map.erase(body_rid)

func _create_area_shape(new_area_data: AreaData) -> void:
	if new_area_data.shape_resource is CircleShape2D:
		shape_rid = PhysicsServer2D.circle_shape_create()
		PhysicsServer2D.shape_set_data(shape_rid, new_area_data.shape_resource.radius)
	elif new_area_data.shape_resource is RectangleShape2D:
		shape_rid = PhysicsServer2D.rectangle_shape_create()
		PhysicsServer2D.shape_set_data(shape_rid, new_area_data.shape_resource.size * 0.5)  # extents = size/2
	elif new_area_data.shape_resource is CapsuleShape2D:
		shape_rid = PhysicsServer2D.capsule_shape_create()
		PhysicsServer2D.shape_set_data(shape_rid, Vector2(new_area_data.shape_resource.radius, new_area_data.shape_resource.height))
	elif new_area_data.shape_resource is ConvexPolygonShape2D:
		shape_rid = PhysicsServer2D.convex_polygon_shape_create()
		PhysicsServer2D.shape_set_data(shape_rid, new_area_data.shape_resource.points)
	elif new_area_data.shape_resource is ConcavePolygonShape2D:
		shape_rid = PhysicsServer2D.concave_polygon_shape_create()
		PhysicsServer2D.shape_set_data(shape_rid, new_area_data.shape_resource.segments)
	else:
		push_error("Unsupported shape type: " + str(new_area_data.shape_resource.get_class()))
