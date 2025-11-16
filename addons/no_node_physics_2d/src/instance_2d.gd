extends RefCounted
class_name Instance2D

# 内部状态
var _position: Vector2 = Vector2.ZERO
var _rotation: float = 0.0
var _scale: Vector2 = Vector2.ONE
var _skew: float = 0.0

# 缓存的变换矩阵和脏标记
var _transform: Transform2D = Transform2D.IDENTITY
var _transform_dirty: bool = true

# 全局变换支持
var _global_transform: Transform2D = Transform2D.IDENTITY
var _global_transform_dirty: bool = true
var base_transform: Transform2D = Transform2D.IDENTITY  # 持有者的全局变换

# 公共接口 - 本地变换属性
var position: Vector2:
	get: 
		_update_transform_values_if_dirty()
		return _position
	set(value):
		_position = value
		_mark_transform_dirty()

var rotation: float:
	get:
		_update_transform_values_if_dirty()
		return _rotation
	set(value):
		_rotation = value
		_mark_transform_dirty()

var scale: Vector2:
	get:
		_update_transform_values_if_dirty()
		return _scale
	set(value):
		# 防止零缩放，与Node2D使用相同的阈值
		var safe_scale = value
		if abs(safe_scale.x) < 0.0001:
			push_warning("new scale.x is near 0!")
			safe_scale.x = 0.0001
		if abs(safe_scale.y) < 0.0001:
			push_warning("new scale.y is near 0!")
			safe_scale.y = 0.0001
		_scale = safe_scale
		_mark_transform_dirty()

var skew: float:
	get:
		_update_transform_values_if_dirty()
		return _skew
	set(value):
		_skew = value
		_mark_transform_dirty()

var transform: Transform2D:
	get:
		_update_transform_if_dirty()
		return _transform
	set(value):
		_transform = value
		_mark_transform_values_dirty()

# 全局变换属性
var global_transform: Transform2D:
	get:
		_update_global_transform_if_dirty()
		return _global_transform
	set(value):
		# 检查基础变换是否可逆（通过行列式）
		if abs(base_transform.determinant()) > 0.0001:  # 使用determinant()替代is_invertible
			transform = base_transform.affine_inverse() * value
		else:
			transform = value

var global_position: Vector2:
	get: return global_transform.origin
	set(value):
		if abs(base_transform.determinant()) > 0.0001:
			position = base_transform.affine_inverse() * value
		else:
			position = value

# 脏标记管理
func _mark_transform_dirty():
	_transform_dirty = true
	_global_transform_dirty = true

func _mark_transform_values_dirty():
	_transform_dirty = false
	_global_transform_dirty = true

func _update_transform_if_dirty():
	if _transform_dirty:
		# 根据文档，使用Transform2D(rotation: float, scale: Vector2, skew: float, position: Vector2)
		_transform = Transform2D(_rotation, _scale, _skew, _position)
		_transform_dirty = false

func _update_transform_values_if_dirty():
	if _transform_dirty:
		_update_transform_if_dirty()
	# 从矩阵中提取分解值
	_rotation = _transform.get_rotation()
	_skew = _transform.get_skew()
	_position = _transform.origin
	_scale = _transform.get_scale()
	_transform_dirty = false

func _update_global_transform_if_dirty():
	if _global_transform_dirty:
		_update_transform_if_dirty()
		_global_transform = base_transform * _transform
		_global_transform_dirty = false

# 变换操作方法
func translate(offset: Vector2):
	position += offset

func rotate(radians: float):
	rotation += radians

func apply_scale(ratio: Vector2):
	scale *= ratio

func look_at(target: Vector2):
	var local_target = to_local(target)
	rotation = local_target.angle()

func get_angle_to(target: Vector2) -> float:
	var local_target = to_local(target)
	return local_target.angle()

# 坐标转换方法 - 使用完整的仿射变换
func to_local(global_point: Vector2) -> Vector2:
	return global_transform.affine_inverse() * global_point

func to_global(local_point: Vector2) -> Vector2:
	return global_transform * local_point

# 设置基础变换（由持有者调用）
func set_base_transform(new_base: Transform2D):
	if base_transform != new_base:
		base_transform = new_base
		_global_transform_dirty = true

# 重置变换
func reset_transform():
	_position = Vector2.ZERO
	_rotation = 0.0
	_scale = Vector2.ONE
	_skew = 0.0
	_mark_transform_dirty()

# 便捷方法
func set_global_position_safe(global_pos: Vector2):
	# 安全设置全局位置，避免矩阵求逆问题
	if abs(base_transform.determinant()) > 0.0001:
		global_position = global_pos
	else:
		position = global_pos

func copy_from(other: Instance2D):
	# 复制另一个实例的变换
	base_transform = other.base_transform
	transform = other.transform

# 便捷的静态构造方法
static func create_at_position(pos: Vector2) -> Instance2D:
	var instance = Instance2D.new()
	instance.position = pos
	return instance

static func create_with_transform(xform: Transform2D) -> Instance2D:
	var instance = Instance2D.new()
	instance.transform = xform
	return instance
