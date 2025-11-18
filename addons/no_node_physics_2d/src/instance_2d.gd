extends RefCounted
class_name Instance2D

# 私有变量，通过 get/set 方法访问
var _rotation:float = 0.0
var _skew:float = 0.0
var _position:Vector2 = Vector2.ZERO
var _scale:Vector2 = Vector2.ONE
var _transform:Transform2D

var _xform_dirty:bool = false

var _global_position:Vector2 = Vector2.ZERO
var _global_rotation:float = 0.0
var _global_skew:float = 0.0
var _global_scale:Vector2 = Vector2.ONE
var _global_transform:Transform2D

var _global_invalid:bool = true

## 替代原有的parent
var base_transform:Transform2D = Transform2D():
	set = set_base_transform

## 公共属性访问器 TODO:思考怎么直接存值而不需要`_*`变量
var rotation:float:
	get = get_rotation,
	set = set_rotation

var rotation_degrees:float:
	get = get_rotation_degrees,
	set = set_rotation_degrees

var skew:float:
	get = get_skew,
	set = set_skew

var position:Vector2:
	get = get_position,
	set = set_position

var scale:Vector2:
	get = get_scale,
	set = set_scale

var transform:Transform2D:
	get = get_transform,
	set = set_transform

var global_position:Vector2:
	get = get_global_position,
	set = set_global_position

var global_rotation:float:
	get = get_global_rotation,
	set = set_global_rotation

var global_rotation_degrees:float:
	get = get_global_rotation_degrees,
	set = set_global_rotation_degrees

var global_skew:float:
	get = get_global_skew,
	set = set_global_skew

var global_scale:Vector2:
	get = get_global_scale,
	set = set_global_scale

var global_transform:Transform2D:
	get = get_global_transform,
	set = set_global_transform

# 内部方法
func _set_xform_dirty(is_dirty:bool):
	_xform_dirty = is_dirty

func _is_xform_dirty()->bool:
	return _xform_dirty

func _update_xform_values():
	_rotation = _transform.get_rotation()
	_skew = _transform.get_skew()
	_position = _transform.get_origin()
	_scale = _transform.get_scale()
	_set_xform_dirty(false)

func _update_transform():
	_transform = Transform2D(_rotation, _scale, _skew, _position)
	_notify_transform()

func _is_base_transform_identity()->bool:
	return base_transform == Transform2D.IDENTITY

func set_base_transform(new_transform:Transform2D):
	if not new_transform.is_equal_approx(base_transform):
		#_global_invalid = true
		_notify_transform()
	base_transform = new_transform

func set_position(pos:Vector2):
	if _is_xform_dirty():
		_update_xform_values()
	_position = pos
	_update_transform()

func set_rotation(radians:float):
	if _is_xform_dirty():
		_update_xform_values()
	_rotation = radians
	_update_transform()

func set_rotation_degrees(degrees:float):
	set_rotation(deg_to_rad(degrees))

func set_skew(radians:float):
	if _is_xform_dirty():
		_update_xform_values()
	_skew = radians
	_update_transform()

func set_scale(new_scale:Vector2):
	if _is_xform_dirty():
		_update_xform_values()
	_scale = new_scale
	if is_zero_approx(_scale.x):
		_scale.x = 0.00001
	if is_zero_approx(_scale.y):
		_scale.y = 0.00001
	_update_transform()

func get_position()->Vector2:
	if _is_xform_dirty():
		_update_xform_values()
	return _position

func get_rotation()->float:
	if _is_xform_dirty():
		_update_xform_values()
	return _rotation

func get_rotation_degrees()->float:
	return rad_to_deg(get_rotation())

func get_skew()->float:
	if _is_xform_dirty():
		_update_xform_values()
	return _skew

func get_scale()->Vector2:
	if _is_xform_dirty():
		_update_xform_values()
	return _scale

func get_transform()->Transform2D:
	return _transform

func set_transform(new_transform:Transform2D):
	_transform = new_transform
	_set_xform_dirty(true)
	_notify_transform()

func rotate(radians:float):
	set_rotation(get_rotation() + radians)

func translate(amount:Vector2):
	set_position(get_position() + amount)

func apply_scale(amount:Vector2):
	set_scale(get_scale() * amount)

func move_x(delta: float, scaled: bool = false):
	var t = get_transform()
	var axis = t.x  # 局部X轴方向
	if not scaled:
		axis = axis.normalized()
	set_position(t.origin + axis * delta)

func move_y(delta: float, scaled: bool = false):
	var t = get_transform()
	var axis = t.y  # 局部Y轴方向
	if not scaled:
		axis = axis.normalized()
	set_position(t.origin + axis * delta)

func get_global_position()->Vector2:
	return get_global_transform().get_origin()

func set_global_position(new_position:Vector2):
	if not _is_base_transform_identity():
		var inv = base_transform.affine_inverse()
		set_position(inv * new_position)
	else:
		set_position(new_position)

func get_global_rotation()->float:
	return get_global_transform().get_rotation()

func get_global_rotation_degrees()->float:
	return rad_to_deg(get_global_rotation())

func get_global_skew()->float:
	return get_global_transform().get_skew()

func set_global_rotation(new_rotation:float):
	if not _is_base_transform_identity():
		var new_transform = base_transform * get_transform()
		new_transform.set_rotation(new_rotation)
		new_transform = base_transform.affine_inverse() * new_transform
		set_rotation(new_transform.get_rotation())
	else:
		set_rotation(new_rotation)

func set_global_rotation_degrees(degrees:float):
	set_global_rotation(deg_to_rad(degrees))

func set_global_skew(new_skew:float):
	if not _is_base_transform_identity():
		var new_transform = base_transform * get_transform()
		new_transform.set_skew(new_skew)
		new_transform = base_transform.affine_inverse() * new_transform
		set_skew(new_transform.get_skew())
	else:
		set_skew(new_skew)

func get_global_scale()->Vector2:
	return get_global_transform().get_scale()

func set_global_scale(new_scale:Vector2):
	if not _is_base_transform_identity():
		var new_transform = base_transform * get_transform()
		new_transform.set_scale(new_scale)
		new_transform = base_transform.affine_inverse() * new_transform
		set_scale(new_transform.get_scale())
	else:
		set_scale(new_scale)

func get_global_transform()->Transform2D:
	if _global_invalid:
		var new_global_transform = Transform2D()
		if not _is_base_transform_identity():
			new_global_transform = base_transform * get_transform()
		else:
			new_global_transform = get_transform()
		_global_invalid = false
		_global_transform = new_global_transform
	return _global_transform

func set_global_transform(new_global_transform:Transform2D):
	if not _is_base_transform_identity():
		set_transform(base_transform.affine_inverse() * new_global_transform)
	else:
		set_transform(new_global_transform)

func look_at(pos:Vector2):
	rotate(get_angle_to(pos))

func get_angle_to(pos:Vector2):
	return (to_local(pos) * get_scale()).angle()

# 将局部坐标转换为全局坐标
func to_global(local: Vector2) -> Vector2:
	# 等价于 xform：应用全局变换的基和原点（含平移）
	return get_global_transform() * local

# 将全局坐标转换为局部坐标
func to_local(global: Vector2) -> Vector2:
	# 先求全局变换的逆，再应用完整变换（含平移的逆）
	return get_global_transform().affine_inverse() * global

func _notify_transform():
	_global_invalid = true
