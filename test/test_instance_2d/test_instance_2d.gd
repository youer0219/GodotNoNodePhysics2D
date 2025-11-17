# test_instance_2d.gd
# Instance2D类的完整测试脚本
# 该脚本测试Instance2D的所有核心功能

extends Node

# 测试入口函数
func _ready():
	print("开始测试Instance2D类...")
	
	# 运行所有测试
	test_basic_properties()
	test_transform_consistency()
	test_global_transform()
	test_coordinate_conversion()
	test_transform_operations()
	test_look_at_and_angle_to()
	test_edge_cases()
	test_copy_functionality()
	test_static_constructors()
	
	print("所有测试完成！")

# 测试1: 基本属性的getter/setter功能
func test_basic_properties():
	print("测试基本属性...")
	
	var instance = Instance2D.new()
	
	# 测试位置属性
	var test_position = Vector2(10, 20)
	instance.position = test_position
	assert(instance.position == test_position, "位置属性getter/setter测试失败")
	
	# 测试旋转属性
	var test_rotation = 1.57
	instance.rotation = test_rotation
	assert(abs(instance.rotation - test_rotation) < 0.001, "旋转属性getter/setter测试失败")
	
	# 测试缩放属性
	var test_scale = Vector2(2, 3)
	instance.scale = test_scale
	assert(instance.scale == test_scale, "缩放属性getter/setter测试失败")
	
	# 测试倾斜属性
	var test_skew = 0.5
	instance.skew = test_skew
	assert(abs(instance.skew - test_skew) < 0.001, "倾斜属性getter/setter测试失败")
	
	print("基本属性测试通过")

# 测试2: 变换矩阵与分量的一致性
func test_transform_consistency():
	print("测试变换矩阵一致性...")
	
	var instance = Instance2D.new()
	
	# 设置各个变换分量
	var position = Vector2(10, 20)
	var rotation = 1.57
	var scale = Vector2(2, 3)
	var skew = 0.5
	
	instance.position = position
	instance.rotation = rotation
	instance.scale = scale
	instance.skew = skew
	
	# 检查transform矩阵是否正确构建
	var expected_transform = Transform2D(rotation, scale, skew, position)
	assert(instance.transform.is_equal_approx(expected_transform), "变换矩阵一致性测试失败")
	
	print("变换矩阵一致性测试通过")

# 测试3: 全局变换计算
func test_global_transform():
	print("测试全局变换...")
	
	var instance = Instance2D.new()
	
	# 设置基础变换（模拟父节点的全局变换）
	var parent_transform = Transform2D(0, Vector2(2, 2), 0, Vector2(100, 100))
	instance.set_base_transform(parent_transform)
	
	# 设置局部变换
	var local_position = Vector2(10, 20)
	instance.position = local_position
	
	# 计算期望的全局变换
	var expected_global = parent_transform * Transform2D(0, Vector2.ONE, 0, local_position)
	assert(instance.global_transform.is_equal_approx(expected_global), "全局变换计算测试失败")
	
	# 测试全局位置
	var expected_global_position = expected_global.origin
	assert(instance.global_position.is_equal_approx(expected_global_position), "全局位置计算测试失败")
	
	print("全局变换测试通过")

# 测试4: 坐标转换方法
func test_coordinate_conversion():
	print("测试坐标转换...")
	
	var instance = Instance2D.new()
	instance.position = Vector2(100, 50)
	instance.rotation = 0.5
	instance.scale = Vector2(2, 2)
	
	# 测试局部到全局转换
	var local_point = Vector2(10, 0)
	var global_point = instance.to_global(local_point)
	var expected_global = instance.global_transform * local_point
	assert(global_point.is_equal_approx(expected_global), "局部到全局坐标转换测试失败")
	
	# 测试全局到局部转换
	var converted_back = instance.to_local(global_point)
	assert(converted_back.is_equal_approx(local_point), "全局到局部坐标转换测试失败")
	
	print("坐标转换测试通过")

# 测试5: 变换操作方法
func test_transform_operations():
	print("测试变换操作方法...")
	
	var instance = Instance2D.new()
	var original_position = Vector2(10, 20)
	instance.position = original_position
	
	# 测试translate方法
	var offset = Vector2(5, 10)
	instance.translate(offset)
	assert(instance.position.is_equal_approx(original_position + offset), "translate方法测试失败")
	
	# 测试rotate方法
	var original_rotation = 0.5
	instance.rotation = original_rotation
	var rotation_delta = 0.3
	instance.rotate(rotation_delta)
	assert(abs(instance.rotation - (original_rotation + rotation_delta)) < 0.001, "rotate方法测试失败")
	
	# 测试apply_scale方法
	var original_scale = Vector2(2, 3)
	instance.scale = original_scale
	var scale_ratio = Vector2(1.5, 2)
	instance.apply_scale(scale_ratio)
	assert(instance.scale.is_equal_approx(original_scale * scale_ratio), "apply_scale方法测试失败")
	
	print("变换操作方法测试通过")

# 测试6: look_at和get_angle_to方法
func test_look_at_and_angle_to():
	print("测试look_at和get_angle_to方法...")
	
	var instance = Instance2D.new()
	instance.position = Vector2(0, 0)
	
	# 测试look_at方法
	var target = Vector2(10, 0)
	instance.look_at(target)
	# 当朝向x轴正方向时，旋转应接近0
	assert(abs(instance.rotation) < 0.001, "look_at方法测试失败")
	
	# 测试get_angle_to方法
	var angle = instance.get_angle_to(Vector2(0, 10))
	# 从原点朝向(0,10)应该是90度，即PI/2
	assert(abs(angle - PI/2) < 0.001, "get_angle_to方法测试失败")
	
	print("look_at和get_angle_to方法测试通过")

# 测试7: 边界条件
func test_edge_cases():
	print("测试边界条件...")
	
	var instance = Instance2D.new()
	
	# 测试零缩放保护
	instance.scale = Vector2(0, 0)
	assert(abs(instance.scale.x - 0.0001) < 0.00001, "零缩放保护测试失败(x轴): " + str(instance.scale.x))
	assert(abs(instance.scale.y - 0.0001) < 0.00001, "零缩放保护测试失败(y轴): " + str(instance.scale.y))
	
	# 测试非常接近零的缩放值（会被is_zero_approx判定为接近零）
	instance.scale = Vector2(0.000001, 0.000001)  # 远小于CMP_EPSILON (0.00001)
	assert(abs(instance.scale.x - 0.0001) < 0.00001, "接近零缩放值处理测试失败(x轴): " + str(instance.scale.x))
	assert(abs(instance.scale.y - 0.0001) < 0.00001, "接近零缩放值处理测试失败(y轴): " + str(instance.scale.y))
	
	# 测试正常的缩放值（不会被is_zero_approx判定为接近零）
	instance.scale = Vector2(0.1, 0.2)
	assert(abs(instance.scale.x - 0.1) < 0.00001, "正常缩放值处理测试失败(x轴): " + str(instance.scale.x))
	assert(abs(instance.scale.y - 0.2) < 0.00001, "正常缩放值处理测试失败(y轴): " + str(instance.scale.y))
	
	print("边界条件测试通过")

# 测试8: 复制功能
func test_copy_functionality():
	print("测试复制功能...")
	
	var instance1 = Instance2D.new()
	instance1.position = Vector2(10, 20)
	instance1.rotation = 1.5
	instance1.scale = Vector2(2, 3)
	instance1.skew = 0.5
	
	var instance2 = Instance2D.new()
	instance2.copy_from(instance1)
	
	assert(instance2.position == instance1.position, "复制位置测试失败")
	assert(abs(instance2.rotation - instance1.rotation) < 0.001, "复制旋转测试失败")
	assert(instance2.scale == instance1.scale, "复制缩放测试失败")
	assert(abs(instance2.skew - instance1.skew) < 0.001, "复制倾斜测试失败")
	
	print("复制功能测试通过")

# 测试9: 静态构造方法
func test_static_constructors():
	print("测试静态构造方法...")
	
	# 测试create_at_position方法
	var pos = Vector2(50, 100)
	var instance1 = Instance2D.create_at_position(pos)
	assert(instance1.position == pos, "create_at_position方法测试失败")
	
	# 测试create_with_transform方法
	var transform = Transform2D(1.0, Vector2(2, 2), 0.1, Vector2(10, 20))
	var instance2 = Instance2D.create_with_transform(transform)
	assert(instance2.transform.is_equal_approx(transform), "create_with_transform方法测试失败")
	
	print("静态构造方法测试通过")
