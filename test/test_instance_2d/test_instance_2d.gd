# test_instance_2d.gd
# Instance2D类的完整测试脚本
# 该脚本测试Instance2D的所有核心功能

extends Node2D

var instance2d:Instance2D

## 目前启动一个跟随功能，需要：
## 父节点启动set_notify_transform通知，在_notification中告知instance2d
## 同时还要求将父节点作为parent
## TODO: 可能会尝试简化功能或换新的设计方法，特别是instance目前不打算设计为嵌套，所以可以作一些简化

func _ready():
	print("开始测试 Instance2D 类")
	
	# 启用变换通知，这样当Node2D变换改变时会触发NOTIFICATION_TRANSFORM_CHANGED
	set_notify_transform(true)
	
	# 测试基本属性设置和获取
	test_basic_properties()
	
	# 测试变换操作
	test_transform_operations()
	
	# 测试父子关系和全局变换
	test_parent_child_relationships()
	
	# 测试坐标转换
	test_coordinate_transforms()
	
	# 测试角度相关功能
	test_angle_functions()
	
	# 测试其他功能
	test_other_functions()
	
	print("所有测试完成！")

func test_basic_properties():
	print("测试基本属性...")
	
	# 每个测试函数都创建新的Instance2D实例以避免状态污染
	instance2d = Instance2D.new()
	
	# 测试位置设置和获取
	instance2d.position = Vector2(100, 50)
	assert(instance2d.position == Vector2(100, 50), "位置设置失败")
	
	# 测试旋转设置和获取（弧度制）
	instance2d.rotation = PI / 4  # 45度
	assert(abs(instance2d.rotation - PI / 4) < 0.001, "旋转设置失败")
	
	# 测试倾斜设置和获取（弧度制）
	instance2d.skew = PI / 8  # 22.5度
	assert(abs(instance2d.skew - PI / 8) < 0.001, "倾斜设置失败")
	
	# 测试缩放设置和获取
	instance2d.scale = Vector2(2, 1.5)
	assert(instance2d.scale == Vector2(2, 1.5), "缩放设置失败")
	
	# 测试角度转换功能（弧度与度数互转）
	instance2d.rotation_degrees = 90
	assert(abs(instance2d.rotation_degrees - 90) < 0.001, "角度设置失败")
	assert(abs(instance2d.rotation - PI / 2) < 0.001, "角度转换失败")
	
	print("基本属性测试通过")

func test_transform_operations():
	print("测试变换操作...")
	
	# 重置变换 - 创建新实例
	instance2d = Instance2D.new()
	
	# 测试旋转操作：在当前旋转基础上增加指定弧度
	instance2d.rotate(PI / 6)  # 30度
	assert(abs(instance2d.rotation - PI / 6) < 0.001, "旋转操作失败")
	
	# 测试平移操作：在当前位置基础上增加指定偏移
	instance2d.translate(Vector2(50, 30))
	assert(instance2d.position == Vector2(50, 30), "平移操作失败")
	
	# 测试缩放应用操作：当前缩放乘以指定缩放因子
	instance2d.scale = Vector2(2, 1.5)  # 设置初始缩放
	instance2d.apply_scale(Vector2(1.5, 2))  # 应用缩放因子
	# 计算：(2, 1.5) * (1.5, 2) = (3, 3)
	assert(instance2d.scale == Vector2(3, 3), "缩放应用失败")
	
	# 测试沿X轴移动（未缩放模式）：
	# move_x会沿着对象的局部X轴方向移动指定距离
	# 未缩放模式意味着移动距离不考虑对象的缩放影响，使用单位化后的轴向量
	instance2d.position = Vector2.ZERO
	instance2d.rotation = 0  # 旋转为0度
	var old_pos = instance2d.position  # (0,0)
	var initial_rotation_for_move = instance2d.rotation  # 0度
	instance2d.move_x(20, false)  # 未缩放模式，移动20单位
	# 期望位置：原位置 + (20, 0).rotated(0) = (0,0) + (20, 0) = (20, 0)
	var expected_new_pos = old_pos + Vector2(20, 0).rotated(initial_rotation_for_move)
	assert(instance2d.position.distance_to(expected_new_pos) < 0.001, "X轴移动（未缩放）失败")
	
	# 重置位置进行Y轴测试
	instance2d.position = Vector2.ZERO
	instance2d.rotation = 0
	
	# 测试沿Y轴移动（未缩放模式）：
	# move_y会沿着对象的局部Y轴方向移动指定距离
	old_pos = instance2d.position  # (0,0)
	initial_rotation_for_move = instance2d.rotation  # 0度
	instance2d.move_y(15, false)  # 未缩放模式，移动15单位
	# 期望位置：原位置 + (0, 15).rotated(0) = (0,0) + (0, 15) = (0, 15)
	expected_new_pos = old_pos + Vector2(0, 15).rotated(initial_rotation_for_move)
	var actual_new_pos = instance2d.position  # 实际移动后的位置
	assert(actual_new_pos.distance_to(expected_new_pos) < 0.001, "Y轴移动（未缩放）失败")
	
	print("变换操作测试通过")

func test_parent_child_relationships():
	print("测试父子关系...")
	
	# 创建Instance2D实例并设置父节点为当前Node2D
	instance2d = Instance2D.new()
	instance2d.set_parent(self)
	
	# 验证父子关系下的全局位置更新
	# 当父节点（Node2D）移动时，子节点（Instance2D）的全局位置应该跟随变化
	# 但局部位置保持不变
	var test_move := Vector2(10, 10)  # 测试移动向量
	self.global_position = test_move  # 移动父节点
	
	# 验证：Instance2D的局部位置不应改变
	assert(instance2d.position == Vector2.ZERO, "instance的局部位置不应该改变")
	
	# 验证：Instance2D的全局位置应该跟随父节点变化
	assert(instance2d.global_position == test_move, "instance的全局位置应该跟随着改变")
	
	# 重置父节点位置
	self.global_position = Vector2.ZERO
	
	print("父子关系测试通过")

func test_coordinate_transforms():
	print("测试坐标转换...")
	
	# 创建新实例
	instance2d = Instance2D.new()
	
	# 测试局部坐标到全局坐标的转换
	# to_global(local) = get_global_transform() * local
	var local_point = Vector2(10, 20)  # 局部坐标点
	var global_point = instance2d.to_global(local_point)  # 转换为全局坐标
	var expected_global = instance2d.get_global_transform() * local_point  # 期望的全局坐标
	assert(global_point.distance_to(expected_global) < 0.1, "局部到全局转换失败")
	
	# 测试全局坐标到局部坐标的转换
	# to_local(global) = get_global_transform().affine_inverse() * global
	var back_to_local = instance2d.to_local(global_point)  # 将全局坐标转换回局部
	assert(back_to_local.distance_to(local_point) < 0.1, "全局到局部转换失败")
	
	# 验证坐标转换的可逆性：局部→全局→局部 应该回到原始点
	var test_point = Vector2(5, 10)  # 测试点
	var converted = instance2d.to_local(instance2d.to_global(test_point))  # 双向转换
	assert(converted.distance_to(test_point) < 0.1, "坐标转换不可逆")
	
	print("坐标转换测试通过")

func test_angle_functions():
	print("测试角度函数...")
	
	# 创建新的实例以避免状态污染
	instance2d = Instance2D.new()
	
	# 测试 look_at 功能：使对象朝向指定目标点
	# 实现：rotate(get_angle_to(pos))
	var target_pos = Vector2(100, 100)  # 目标位置
	var initial_rotation = instance2d.rotation  # 初始旋转角度（0）
	instance2d.look_at(target_pos)  # 朝向目标点
	# 验证：旋转角度应该发生变化
	assert(abs(instance2d.rotation - initial_rotation) > 0.001, "look_at 未改变旋转")
	
	# 测试 get_angle_to 功能 - 按照原始实现逻辑
	# Godot原始实现：(to_local(pos) * get_scale()).angle()
	# to_local(pos) = 将全局坐标转换到局部坐标系
	# * get_scale() = 将局部坐标乘以当前缩放
	# .angle() = 计算向量的角度
	var angle_to_target = instance2d.get_angle_to(target_pos)  # 实际计算的角度
	# 按照原始实现逐步计算期望角度
	var local_pos = instance2d.to_local(target_pos)  # 转换目标点到局部坐标
	var scaled_local_pos = local_pos * instance2d.get_scale()  # 乘以当前缩放
	var expected_angle = scaled_local_pos.angle()  # 计算向量角度
	assert(abs(angle_to_target - expected_angle) < 0.001, "get_angle_to 计算错误")
	
	# 测试不同变换下的 get_angle_to
	instance2d.position = Vector2(10, 20)  # 设置新位置
	instance2d.rotation = PI/4  # 45度旋转
	instance2d.scale = Vector2(2, 1.5)  # 设置缩放
	var new_target = Vector2(60, 70)  # 新目标点
	angle_to_target = instance2d.get_angle_to(new_target)  # 计算角度
	# 逐步验证计算过程
	local_pos = instance2d.to_local(new_target)  # 转换到局部坐标
	scaled_local_pos = local_pos * instance2d.get_scale()  # 乘以缩放
	expected_angle = scaled_local_pos.angle()  # 计算角度
	assert(abs(angle_to_target - expected_angle) < 0.001, "get_angle_to 计算错误（变换后）")
	
	print("角度函数测试通过")

func test_other_functions():
	print("测试其他功能...")
	
	# 创建新实例
	instance2d = Instance2D.new()
	
	# 测试 Transform2D 直接设置和获取
	# Transform2D(rotation, scale, skew, origin)
	var test_transform = Transform2D(PI / 3, Vector2(1.5, 2), PI / 6, Vector2(50, 30))
	instance2d.set_transform(test_transform)
	assert(instance2d.get_transform().is_equal_approx(test_transform), "Transform2D 设置失败")
	
	# 验证设置 Transform2D 后各个分量是否正确提取
	assert(abs(instance2d.rotation - PI / 3) < 0.001, "Transform2D 旋转提取失败")
	assert(instance2d.scale.distance_to(Vector2(1.5, 2)) < 0.001, "Transform2D 缩放提取失败")
	assert(instance2d.position.distance_to(Vector2(50, 30)) < 0.001, "Transform2D 位置提取失败")
	assert(abs(instance2d.skew - PI / 6) < 0.001, "Transform2D 倾斜提取失败")
	
	# 测试零缩放处理：当缩放为0时，自动设置为极小值避免除零错误
	instance2d.scale = Vector2(0, 1)  # X轴缩放为0
	assert(abs(instance2d.scale.x - 0.00001) < 0.000001, "零缩放处理失败")
	
	instance2d.scale = Vector2(1, 0)  # Y轴缩放为0
	assert(abs(instance2d.scale.y - 0.00001) < 0.000001, "零缩放处理失败")
	
	# 重置缩放
	instance2d.scale = Vector2.ONE
	
	# 测试全局变换无效标记：通知系统全局变换需要重新计算
	instance2d._notify_transform()  # 标记全局变换无效
	assert(instance2d._global_invalid == true, "全局变换无效标记失败")
	
	# 测试全局变换计算：获取有效的全局变换矩阵
	var global_t = instance2d.get_global_transform()  # 获取全局变换
	assert(global_t != Transform2D(), "全局变换计算失败")
	
	print("其他功能测试通过")

func _notification(what: int) -> void:
	# 监听变换变化通知，当父节点变换改变时通知子节点
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			# 标记Instance2D的全局变换为无效，下次访问时会重新计算
			instance2d.set_global_invalid(true)
