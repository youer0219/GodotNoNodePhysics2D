# test_instance_2d.gd
# Instance2D类的完整测试脚本
# 该脚本测试Instance2D的所有核心功能

extends Node2D

var instance2d:Instance2D

## 目前启动一个跟随功能，需要：
## 父节点使用 set_notify_local_transform 启动通知，并在 _notification 中设定实例2D的基础变换值

func _ready():
	print("开始测试 Instance2D 类")
	
	# 启用变换通知，这样当Node2D变换改变时会触发NOTIFICATION_TRANSFORM_CHANGED
	# 这样当父节点（Node2D）的变换发生变化时，会通过_notification函数通知子节点
	# set_notify_transform(true) ## 此通知失效，原因未知。但local通知可用。
	set_notify_local_transform(true)
	
	# 测试基本属性设置和获取
	test_basic_properties()
	
	# 测试变换操作
	test_transform_operations()
	
	test_parent_child_relationships()
	
	# 测试父子关系和全局变换
	test_complex_parent_transforms()
	
	# 测试坐标转换
	test_coordinate_transforms()
	
	# 测试角度相关功能
	test_angle_functions()
	
	# 测试复杂变换组合
	test_complex_transforms()
	
	# 测试边界情况
	test_edge_cases()
	
	# 测试其他功能
	test_other_functions()
	
	print("所有测试完成！")

func test_basic_properties():
	print("测试基本属性...")
	
	# 每个测试函数都创建新的Instance2D实例以避免状态污染
	# 避免前一个测试的状态影响当前测试结果
	instance2d = Instance2D.new()
	
	# 测试位置设置和获取
	# 验证 position 属性的 setter 和 getter 是否正常工作
	instance2d.position = Vector2(100, 50)
	assert(instance2d.position == Vector2(100, 50), "位置设置失败")
	
	# 测试旋转设置和获取（弧度制）
	# 验证 rotation 属性的 setter 和 getter 是否正常工作
	# PI/4 = 45度
	instance2d.rotation = PI / 4  # 45度
	assert(abs(instance2d.rotation - PI / 4) < 0.001, "旋转设置失败")
	
	# 测试倾斜设置和获取（弧度制）
	# 验证 skew 属性的 setter 和 getter 是否正常工作
	# PI/8 = 22.5度
	instance2d.skew = PI / 8  # 22.5度
	assert(abs(instance2d.skew - PI / 8) < 0.001, "倾斜设置失败")
	
	# 测试缩放设置和获取
	# 验证 scale 属性的 setter 和 getter 是否正常工作
	instance2d.scale = Vector2(2, 1.5)
	assert(instance2d.scale == Vector2(2, 1.5), "缩放设置失败")
	
	# 测试角度转换功能（弧度与度数互转）
	# 验证 rotation_degrees 属性是否正确转换为弧度值
	# 90度 = PI/2 弧度
	instance2d.rotation_degrees = 90
	assert(abs(instance2d.rotation_degrees - 90) < 0.001, "角度设置失败")
	assert(abs(instance2d.rotation - PI / 2) < 0.001, "角度转换失败")
	
	print("基本属性测试通过")

func test_transform_operations():
	print("测试变换操作...")
	
	# 重置变换 - 创建新实例
	instance2d = Instance2D.new()
	
	# 测试旋转操作：在当前旋转基础上增加指定弧度
	# rotate方法：get_rotation() + radians
	instance2d.rotate(PI / 6)  # 30度
	# 计算：0 + PI/6 = PI/6
	assert(abs(instance2d.rotation - PI / 6) < 0.001, "旋转操作失败")
	
	# 测试平移操作：在当前位置基础上增加指定偏移
	# translate方法：get_position() + amount
	instance2d.translate(Vector2(50, 30))
	# 计算：(0,0) + (50,30) = (50,30)
	assert(instance2d.position == Vector2(50, 30), "平移操作失败")
	
	# 测试缩放应用操作：当前缩放乘以指定缩放因子
	# apply_scale方法：get_scale() * amount
	instance2d.scale = Vector2(2, 1.5)  # 设置初始缩放
	instance2d.apply_scale(Vector2(1.5, 2))  # 应用缩放因子
	# 计算：(2, 1.5) * (1.5, 2) = (3, 3)
	assert(instance2d.scale == Vector2(3, 3), "缩放应用失败")
	
	# 测试沿X轴移动（未缩放模式）：
	# move_x会沿着对象的局部X轴方向移动指定距离
	# 未缩放模式意味着移动距离不考虑对象的缩放影响，使用单位化后的轴向量
	# move_x逻辑：
	# 1. 获取当前变换矩阵的X轴向量：t.x
	# 2. 如果scaled=false，则单位化该向量
	# 3. 设置新位置：原位置 + 单位化X轴向量 * delta
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
	# move_y逻辑：
	# 1. 获取当前变换矩阵的Y轴向量：t.y
	# 2. 如果scaled=false，则单位化该向量
	# 3. 设置新位置：原位置 + 单位化Y轴向量 * delta
	old_pos = instance2d.position  # (0,0)
	initial_rotation_for_move = instance2d.rotation  # 0度
	instance2d.move_y(15, false)  # 未缩放模式，移动15单位
	# 期望位置：原位置 + (0, 15).rotated(0) = (0,0) + (0, 15) = (0, 15)
	expected_new_pos = old_pos + Vector2(0, 15).rotated(initial_rotation_for_move)
	var actual_new_pos = instance2d.position  # 实际移动后的位置
	assert(actual_new_pos.distance_to(expected_new_pos) < 0.001, "Y轴移动（未缩放）失败")
	
	# 测试旋转后移动X轴（验证局部轴方向）
	# 验证旋转后X轴方向是否正确
	instance2d.position = Vector2.ZERO
	instance2d.rotation = PI/4  # 45度
	old_pos = instance2d.position
	instance2d.move_x(10, false)
	# 当旋转为45度时，X轴方向是(cos(45),sin(45)) = (sqrt(2)/2, sqrt(2)/2)
	var expected_pos = old_pos + Vector2(cos(PI/4), sin(PI/4)) * 10
	assert(instance2d.position.distance_to(expected_pos) < 0.001, "旋转后X轴移动失败")
	
	# 测试旋转后移动Y轴（验证局部轴方向）
	# 验证旋转后Y轴方向是否正确
	instance2d.position = Vector2.ZERO
	instance2d.rotation = PI/4  # 45度
	old_pos = instance2d.position
	instance2d.move_y(10, false)
	# 当旋转为45度时，Y轴方向是(-sin(45),cos(45)) = (-sqrt(2)/2, sqrt(2)/2)
	expected_pos = old_pos + Vector2(-sin(PI/4), cos(PI/4)) * 10
	assert(instance2d.position.distance_to(expected_pos) < 0.001, "旋转后Y轴移动失败")
	
	# 测试缩放模式下的移动
	# 验证scaled=true时是否考虑缩放影响
	instance2d.position = Vector2.ZERO
	instance2d.rotation = 0
	instance2d.scale = Vector2(2, 3)  # X缩放2倍，Y缩放3倍
	old_pos = instance2d.position
	instance2d.move_x(5, true)  # 缩放模式
	# 在缩放模式下，X轴方向是(2,0)，移动5单位后应该是(10,0)
	assert(instance2d.position.distance_to(Vector2(10, 0)) < 0.001, "X轴移动（缩放）失败")
	
	instance2d.position = Vector2.ZERO
	old_pos = instance2d.position
	instance2d.move_y(4, true)  # 缩放模式
	# 在缩放模式下，Y轴方向是(0,3)，移动4单位后应该是(0,12)
	assert(instance2d.position.distance_to(Vector2(0, 12)) < 0.001, "Y轴移动（缩放）失败")
	
	print("变换操作测试通过")

func test_parent_child_relationships():
	print("测试父子关系...")
	
	# 创建Instance2D实例并设置base_transform来模拟父子关系
	instance2d = Instance2D.new()
	
	# 创建父节点变换
	var parent_transform = Transform2D(0, Vector2.ONE, 0, Vector2(10, 10))
	transform = parent_transform
	
	# 验证：Instance2D的局部位置不应改变
	assert(instance2d.position == Vector2.ZERO, "instance的局部位置不应该改变")
	
	# 验证：Instance2D的全局位置应该跟随base_transform变化
	assert(instance2d.global_position.distance_to(Vector2(10, 10)) < 0.001, "instance的全局位置应该跟随着改变")
	
	# 重置base_transform
	self.transform = Transform2D()
	
	print("父子关系测试通过")

func test_complex_parent_transforms():
	print("测试复杂父子变换...")
	
	instance2d = Instance2D.new()
	
	# 测试带旋转和缩放的base_transform
	var complex_base = Transform2D(PI/4, Vector2(2, 1.5), 0, Vector2(50, 30))
	self.transform = complex_base
	instance2d.position = Vector2(10, 5)
	
	# 验证全局变换是否正确组合
	var expected_global = complex_base * instance2d.transform
	var actual_global = instance2d.global_transform
	
	assert(actual_global.is_equal_approx(expected_global), "复杂父子变换计算错误")
	
	# 测试通过base_transform设置全局属性
	var new_global_pos = Vector2(200, 100)
	instance2d.global_position = new_global_pos
	
	# 验证全局位置设置是否正确
	assert(instance2d.global_position.distance_to(new_global_pos) < 0.001, "通过base_transform设置全局位置失败")
	
	print("复杂父子变换测试通过")

func test_complex_transforms():
	print("测试复杂变换组合...")
	
	instance2d = Instance2D.new()
	
	# 同时应用旋转、缩放、倾斜，验证变换矩阵的正确性
	# 设置复杂的变换参数
	instance2d.position = Vector2(50, 30)  # 位置
	instance2d.rotation = PI/3  # 60度旋转
	instance2d.scale = Vector2(1.5, 0.8)  # 非均匀缩放
	instance2d.skew = PI/12  # 15度倾斜
	
	# 验证变换矩阵正确性
	# 从Instance2D的transform属性获取当前变换矩阵
	var t = instance2d.transform
	# 重新构建变换矩阵进行比较
	var reconstructed = Transform2D(instance2d.rotation, instance2d.scale, 
								  instance2d.skew, instance2d.position)
	# 验证两个变换矩阵是否相等
	assert(t.is_equal_approx(reconstructed), "复杂变换组合不正确")

func test_coordinate_transforms():
	print("测试坐标转换...")
	
	# 创建新实例
	instance2d = Instance2D.new()
	
	# 测试局部坐标到全局坐标的转换
	# to_global(local) = get_global_transform() * local
	# 验证局部坐标系中的点是否能正确转换到全局坐标系
	var local_point = Vector2(10, 20)  # 局部坐标点
	var global_point = instance2d.to_global(local_point)  # 转换为全局坐标
	var expected_global = instance2d.get_global_transform() * local_point  # 期望的全局坐标
	assert(global_point.distance_to(expected_global) < 0.1, "局部到全局转换失败")
	
	# 测试全局坐标到局部坐标的转换
	# to_local(global) = get_global_transform().affine_inverse() * global
	# 验证全局坐标系中的点是否能正确转换到局部坐标系
	var back_to_local = instance2d.to_local(global_point)  # 将全局坐标转换回局部
	assert(back_to_local.distance_to(local_point) < 0.1, "全局到局部转换失败")
	
	# 验证坐标转换的可逆性：局部→全局→局部 应该回到原始点
	# 这验证了坐标转换函数的正确性和可逆性
	var test_point = Vector2(5, 10)  # 测试点
	var converted = instance2d.to_local(instance2d.to_global(test_point))  # 双向转换
	assert(converted.distance_to(test_point) < 0.1, "坐标转换不可逆")
	
	# 测试旋转后的坐标转换
	# 验证旋转是否影响坐标转换
	instance2d.rotation = PI/4  # 45度旋转
	local_point = Vector2(10, 0)  # X轴上的点
	global_point = instance2d.to_global(local_point)  # 应该在45度方向上
	expected_global = instance2d.get_global_transform() * local_point
	assert(global_point.distance_to(expected_global) < 0.1, "旋转后局部到全局转换失败")
	
	print("坐标转换测试通过")

func test_angle_functions():
	print("测试角度函数...")
	
	# 创建新的实例以避免状态污染
	instance2d = Instance2D.new()
	
	# 测试 look_at 功能：使对象朝向指定目标点
	# 实现：rotate(get_angle_to(pos))
	# 验证对象是否正确朝向目标点
	var target_pos = Vector2(100, 100)  # 目标位置
	var initial_rotation = instance2d.rotation  # 初始旋转角度（0）
	instance2d.look_at(target_pos)  # 朝向目标点
	# 验证：旋转角度应该发生变化
	assert(abs(instance2d.rotation - initial_rotation) > 0.001, "look_at 未改变旋转")
	
	# 测试 get_angle_to 功能 - 按照原始实现逻辑
	# Godot原始实现：(to_local(pos) * get_scale()).angle()
	# 这个实现的逻辑是：
	# 1. to_local(pos) - 将全局坐标转换到局部坐标系
	# 2. * get_scale() - 将局部坐标乘以当前缩放
	# 3. .angle() - 计算向量的角度
	var angle_to_target = instance2d.get_angle_to(target_pos)  # 实际计算的角度
	# 按照原始实现逐步计算期望角度
	var local_pos = instance2d.to_local(target_pos)  # 转换目标点到局部坐标
	var scaled_local_pos = local_pos * instance2d.get_scale()  # 乘以当前缩放
	var expected_angle = scaled_local_pos.angle()  # 计算向量角度
	assert(abs(angle_to_target - expected_angle) < 0.001, "get_angle_to 计算错误")
	
	# 测试不同变换下的 get_angle_to
	# 验证在不同变换参数下，get_angle_to是否仍然正确计算
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

func test_edge_cases():
	print("测试边界情况...")
	
	# 测试非常大的数值
	# 验证系统在处理大数值时是否正常工作
	instance2d = Instance2D.new()
	instance2d.position = Vector2(1000000, -1000000)
	assert(instance2d.position == Vector2(1000000, -1000000), "大数值位置设置失败")
	
	# 测试负缩放
	# 验证负缩放（镜像）是否正常工作
	instance2d.scale = Vector2(-1, -1)
	assert(instance2d.scale == Vector2(-1, -1), "负缩放设置失败")
	
	# 测试接近0的极小缩放
	# 验证极小缩放值是否正常处理
	instance2d.scale = Vector2(0.000001, 0.000001)
	assert(abs(instance2d.scale.x - 0.000001) < 0.00001 and abs(instance2d.scale.y - 0.000001) < 0.00001, "极小缩放设置失败")
	
	# 测试各种角度值
	# 验证不同角度范围的值是否正确处理
	instance2d.rotation = 2 * PI  # 360度
	assert(abs(instance2d.rotation - 2 * PI) < 0.001, "360度旋转设置失败")
	
	instance2d.rotation = -PI  # -180度
	assert(abs(instance2d.rotation - (-PI)) < 0.001, "负180度旋转设置失败")
	
	# 测试全局变换设置
	# 验证set_global_transform是否正确设置全局变换
	var test_global_transform = Transform2D(PI/2, Vector2(2, 2), PI/4, Vector2(100, 50))
	instance2d.set_global_transform(test_global_transform)
	var actual_global_transform = instance2d.get_global_transform()
	assert(actual_global_transform.is_equal_approx(test_global_transform), "全局变换设置失败")
	
	# 测试全局位置、旋转、缩放设置
	# 验证全局属性的设置和获取是否正确
	var test_global_pos = Vector2(200, 150)
	instance2d.set_global_position(test_global_pos)
	assert(instance2d.get_global_position().distance_to(test_global_pos) < 0.001, "全局位置设置失败")
	
	instance2d.set_global_rotation(PI/3)
	assert(abs(instance2d.get_global_rotation() - PI/3) < 0.001, "全局旋转设置失败")
	
	instance2d.set_global_scale(Vector2(1.5, 1.5))
	assert(instance2d.get_global_scale().distance_to(Vector2(1.5, 1.5)) < 0.001, "全局缩放设置失败")
	
	print("边界情况测试通过")

func test_other_functions():
	print("测试其他功能...")
	
	# 创建新实例
	instance2d = Instance2D.new()
	
	# 测试 Transform2D 直接设置和获取
	# Transform2D(rotation, scale, skew, origin)
	# 验证Transform2D对象的设置和获取是否正确
	var test_transform = Transform2D(PI / 3, Vector2(1.5, 2), PI / 6, Vector2(50, 30))
	instance2d.set_transform(test_transform)
	assert(instance2d.get_transform().is_equal_approx(test_transform), "Transform2D 设置失败")
	
	# 验证设置 Transform2D 后各个分量是否正确提取
	# 确保Transform2D设置后，各个属性都能正确提取出来
	assert(abs(instance2d.rotation - PI / 3) < 0.001, "Transform2D 旋转提取失败")
	assert(instance2d.scale.distance_to(Vector2(1.5, 2)) < 0.001, "Transform2D 缩放提取失败")
	assert(instance2d.position.distance_to(Vector2(50, 30)) < 0.001, "Transform2D 位置提取失败")
	assert(abs(instance2d.skew - PI / 6) < 0.001, "Transform2D 倾斜提取失败")
	
	# 测试零缩放处理：当缩放为0时，自动设置为极小值避免除零错误
	# 验证系统如何处理缩放为0的边界情况
	instance2d.scale = Vector2(0, 1)  # X轴缩放为0
	assert(abs(instance2d.scale.x - 0.00001) < 0.000001, "零缩放处理失败")
	
	instance2d.scale = Vector2(1, 0)  # Y轴缩放为0
	assert(abs(instance2d.scale.y - 0.00001) < 0.000001, "零缩放处理失败")
	
	# 重置缩放
	instance2d.scale = Vector2.ONE
	
	# 测试全局变换无效标记：通知系统全局变换需要重新计算
	# 验证_global_invalid标记的设置和清除是否正确
	instance2d._notify_transform()  # 标记全局变换无效
	assert(instance2d._global_invalid == true, "全局变换无效标记失败")
	
	# 测试全局变换计算：获取有效的全局变换矩阵
	# 验证系统是否能正确计算全局变换
	var global_t = instance2d.get_global_transform()  # 获取全局变换
	assert(global_t != Transform2D(), "全局变换计算失败")
	
	# 验证全局变换计算后标记被清除
	# 确保计算后全局变换标记被正确清除，避免重复计算
	assert(instance2d._global_invalid == false, "全局变换计算后标记未清除")
	
	print("其他功能测试通过")

func _notification(what: int) -> void:
	# 监听变换变化通知，当父节点变换改变时改变实例的base变换
	match what:
		#NOTIFICATION_TRANSFORM_CHANGED:
			#instance2d.base_transform = get_global_transform()
		NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
			instance2d.base_transform = get_global_transform()
