extends Node2D

@export var base_area_data:QuickAreaData

var test_instances: Array[QuickAreaInstance] = []
var monitor_nodes: Array[Area2D] = []

func _ready() -> void:
	print_rich("[color=yellow]=== 开始扩展测试 ===[/color]")
	
	# 依次运行测试
	await run_all_tests()
	
	print_rich("[color=yellow]=== 扩展测试完成 ===[/color]")

func run_all_tests() -> void:
	#base_test()
	await test_lifecycle_management()
	await test_physics_properties()
	await test_shape_functionality()
	@warning_ignore("redundant_await")
	await test_collision_detection()
	await test_edge_cases()

func base_test():
	## 实例创建测试
	var data := base_area_data.duplicate()
	var test_owner_node:Node = Node.new()
	var instance := NoNodePhysicsFactory.create_area(data,test_owner_node)
	var area_rid := instance.area_rid
	var shape_rid := instance.shape_rid
	var instance_id := instance.get_instance_id()
	
	var area2d := get_area_node(data)
	add_child(area2d)
	area2d.area_shape_entered.connect(
		func(x_area_rid: RID, _area: Object, _area_shape_index: int, _local_shape_index: int):
			print("area_shape_entered")
			print("area_rid: ",x_area_rid)
			print("area_rid == x_area_rid: ",area_rid == x_area_rid)
			var id := PhysicsServer2D.area_get_object_instance_id(x_area_rid)
			print("id == instance_id: ",id == instance_id)
	)
	area2d.area_shape_exited.connect(
		func(x_area_rid: RID, _area: Object, _area_shape_index: int, _local_shape_index: int):
			print("area_shape_exited")
			print("area_rid: ",x_area_rid)
			print("area_rid == x_area_rid: ",area_rid == x_area_rid)
	)
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var finded_instance = NoNodePhysicsFactory.get_area_instance_by_rid(area_rid)
	print(finded_instance.get_owner() == test_owner_node)
	
	finded_instance = null
	instance = null
	
	await get_tree().physics_frame
	
	## 判断area-rid和shape-rid被正确释放 注意会出现两个报错
	test_and_print(PhysicsServer2D.area_get_shape_count(area_rid) == -1,
	"实例自动销毁后，原先的area_rid无法使用")
	test_and_print(PhysicsServer2D.shape_get_data(shape_rid) == null,
	"实例自动销毁后，原先的shape-rid无法使用")
	
	print("\n")

#region 1. 生命周期管理测试
func test_lifecycle_management() -> void:
	print_rich("\n[color=cyan]1. 生命周期管理测试[/color]")
	
	await test_reference_counting()
	await test_repeated_creation()

func test_reference_counting() -> void:
	print("  - 引用计数测试")
	
	var owner_node = Node.new()
	var instance = NoNodePhysicsFactory.create_area(base_area_data, owner_node)
	var original_rid = instance.area_rid
	
	# 测试实例ID绑定
	var instance_id = instance.get_instance_id()
	var rid_from_physics = PhysicsServer2D.area_get_object_instance_id(original_rid)
	test_and_print(instance_id == rid_from_physics, "实例ID正确绑定到物理服务")
	
	# 释放instance变量，instance应该自动销毁
	instance = null
	await get_tree().process_frame
	await get_tree().physics_frame
	
	test_and_print(PhysicsServer2D.area_get_shape_count(original_rid) == -1,
		"所有者释放后实例自动销毁")
	
	# 测试结束，清理资源
	owner_node.free()

func test_repeated_creation() -> void:
	print("  - 重复创建销毁测试")
	
	var success_count = 0
	const TEST_COUNT = 5
	
	for i in TEST_COUNT:
		var instance = NoNodePhysicsFactory.create_area(base_area_data, null)
		var rid = instance.area_rid
		
		# 快速创建销毁
		instance = null
		await get_tree().physics_frame
		
		# 检查是否清理
		if !rid.is_valid() or PhysicsServer2D.area_get_shape_count(rid) == -1:
			success_count += 1
	
	test_and_print(success_count == TEST_COUNT, "重复创建销毁稳定性测试")

#endregion

#region 2. 物理属性测试
func test_physics_properties() -> void:
	print_rich("\n[color=cyan]2. 物理属性测试[/color]")
	
	await test_transform_operations()
	await test_collision_layers()
	#await test_monitorable_property()

func test_transform_operations() -> void:
	print("  - 变换操作测试")
	
	var owner_node = Node.new()
	var instance = NoNodePhysicsFactory.create_area(base_area_data, owner_node)
	
	# 测试位置设置
	var test_position = Vector2(100, 50)
	var test_transform = Transform2D(0, test_position)
	instance.set_transform(test_transform)
	
	await get_tree().physics_frame
	
	# 获取物理服务器中的实际变换
	var physics_transform = PhysicsServer2D.area_get_transform(instance.area_rid)
	var position_correct = physics_transform.origin.distance_to(test_position) < 0.01
	test_and_print(position_correct, "位置变换正确应用")
	
	# 测试旋转
	var test_rotation = PI / 4
	var rotated_transform = Transform2D(test_rotation, test_position)
	instance.set_transform(rotated_transform)
	
	await get_tree().physics_frame
	
	physics_transform = PhysicsServer2D.area_get_transform(instance.area_rid)
	var rotation_correct = abs(physics_transform.get_rotation() - test_rotation) < 0.01
	test_and_print(rotation_correct, "旋转变换正确应用")
	
	owner_node.queue_free()

func test_collision_layers() -> void:
	print("  - 碰撞层测试")
	
	var owner_node = Node.new()
	var instance = NoNodePhysicsFactory.create_area(base_area_data, owner_node)
	
	# 测试不同碰撞层
	var test_layers = [1, 2, 4, 8]
	var success = true
	
	for layer in test_layers:
		instance.set_collision_layer(layer)
		await get_tree().physics_frame
		
		var actual_layer = PhysicsServer2D.area_get_collision_layer(instance.area_rid)
		if actual_layer != layer:
			success = false
			break
	
	test_and_print(success, "碰撞层设置正确")
	owner_node.queue_free()

## TODO: 待解决
#func test_monitorable_property() -> void:
	#print("  - 监控属性测试")
	#
	#var owner_node = Node.new()
	#var instance = NoNodePhysicsFactory.create_area(base_area_data, owner_node)
	#
	## 初始应为true（根据数据）
	#var initial_monitorable = PhysicsServer2D.area_is_monitorable(instance.area_rid)
	#test_and_print(initial_monitorable == base_area_data.monitorable, "初始监控属性正确")
	#
	## 切换监控属性
	#instance.monitorable = !base_area_data.monitorable
	#await get_tree().physics_frame
	#
	#var switched_monitorable = PhysicsServer2D.area_is_monitorable(instance.area_rid)
	#test_and_print(switched_monitorable == !base_area_data.monitorable, "监控属性切换正确")
	#
	#owner_node.queue_free()
#endregion

#region 3. 形状功能测试
func test_shape_functionality() -> void:
	print_rich("\n[color=cyan]3. 形状功能测试[/color]")
	
	await test_multiple_shapes()
	await test_shape_transforms()
	#await test_shape_disabling()

func test_multiple_shapes() -> void:
	await get_tree().physics_frame
	print("  - 多种形状测试")
	
	var shapes = [
		{"name": "圆形", "shape": CircleShape2D.new()},
		{"name": "矩形", "shape": RectangleShape2D.new()},
		{"name": "胶囊体", "shape": CapsuleShape2D.new()} 
	]
	
	var success_count = 0
	 
	for shape_data in shapes:
		var shape_resource = shape_data["shape"]
		if shape_resource:
			var area_data = base_area_data.duplicate()
			area_data.shape_resource = shape_resource
			
			var instance = NoNodePhysicsFactory.create_area(area_data, null)
			
			# 检查形状是否成功创建
			var shape_count = PhysicsServer2D.area_get_shape_count(instance.area_rid)
			if shape_count > 0:
				success_count += 1
				print("    ✓ %s形状创建成功" % shape_data["name"])
			else:
				print("    ✗ %s形状创建失败" % shape_data["name"])
			
			instance = null
	
	test_and_print(success_count == shapes.size(), "所有形状类型正确创建")

func test_shape_transforms() -> void:
	print("  - 形状变换测试")
	
	var owner_node = Node.new()
	var instance = NoNodePhysicsFactory.create_area(base_area_data, owner_node)
	
	# 测试形状局部变换
	var shape_transform = Transform2D(PI / 6, Vector2(10, 5))
	instance.set_shape_transform(0, shape_transform)
	
	await get_tree().physics_frame
	
	var actual_transform = PhysicsServer2D.area_get_shape_transform(instance.area_rid, 0)
	var transform_correct = actual_transform.origin.distance_to(shape_transform.origin) < 0.1
	test_and_print(transform_correct, "形状局部变换正确应用")
	
	owner_node.queue_free()

#func test_shape_disabling() -> void:
	#print("  - 形状禁用测试")
	#
	#var owner_node = Node.new()
	#var instance = NoNodePhysicsFactory.create_area(base_area_data, owner_node)
	#
	## 初始应该启用
	#var initial_disabled = PhysicsServer2D.area_is_shape_disabled(instance.area_rid, 0)
	#test_and_print(!initial_disabled, "形状初始为启用状态")
	#
	## 禁用形状
	#instance.set_shape_disabled(0, true)
	#await get_tree().physics_frame
	#
	#var disabled_state = PhysicsServer2D.area_is_shape_disabled(instance.area_rid, 0)
	#test_and_print(disabled_state, "形状成功禁用")
	#
	## 重新启用
	#instance.set_shape_disabled(0, false)
	#await get_tree().physics_frame
	#
	#var enabled_state = !PhysicsServer2D.area_is_shape_disabled(instance.area_rid, 0)
	#test_and_print(enabled_state, "形状成功启用")
	#
	#owner_node.queue_free()
#endregion

#region 4. 碰撞检测测试
func test_collision_detection() -> void:
	print_rich("\n[color=cyan]4. 碰撞检测测试[/color]")
	print("暂时搁置")
	## TODO:解决相关报错
	#await test_static_collision()
	#await test_dynamic_collision()
	#await test_multi_instance_collision()

#func test_static_collision() -> void:
	#print("  - 静态碰撞测试")
	#
	#var collision_detected = false
	#var collision_signal_received = false
	#
	## 创建被检测的QuickAreaInstance
	#var quick_owner = Node.new()
	#var quick_instance = NoNodePhysicsFactory.create_area(base_area_data, quick_owner)
	#quick_instance.set_transform(Transform2D(0, Vector2(200, 200)))
	#
	## 创建检测用的Area2D
	#var detector = Area2D.new()
	#detector.collision_mask = base_area_data.collision_layer
	#detector.collision_layer = 0 # 只检测，不被检测
	#
	#var collision_shape = CollisionShape2D.new()
	#collision_shape.shape = base_area_data.shape_resource
	#detector.add_child(collision_shape)
	#
	#detector.area_entered.connect(func(area):
		#collision_signal_received = true
		#print("    ✓ 碰撞信号触发")
	#)
	#
	#add_child(detector)
	#detector.position = Vector2(200, 200)
	#
	## 等待物理帧处理
	#await get_tree().physics_frame
	#await get_tree().physics_frame
	#
	## 检查重叠
	#var space_state = get_world_2d().direct_space_state
	#var params = PhysicsShapeQueryParameters2D.new()
	#params.shape = base_area_data.shape_resource
	#params.transform = detector.global_transform
	#params.collision_mask = base_area_data.collision_layer
	#
	#var results = space_state.intersect_shape(params)
	#collision_detected = results.size() > 0
	#
	#test_and_print(collision_detected and collision_signal_received, "静态碰撞检测正确")
	#
	#detector.queue_free()
	#quick_owner.queue_free()
#
#func test_dynamic_collision() -> void:
	#print("  - 动态碰撞测试")
	#
	#var collision_occurred = false
	#
	## 创建固定的QuickAreaInstance
	#var fixed_owner = Node.new()
	#var fixed_instance = NoNodePhysicsFactory.create_area(base_area_data, fixed_owner)
	#fixed_instance.set_transform(Transform2D(0, Vector2(300, 300)))
	#
	## 创建移动的检测器
	#var detector = Area2D.new()
	#detector.collision_mask = base_area_data.collision_layer
	#var collision_shape = CollisionShape2D.new()
	#collision_shape.shape = base_area_data.shape_resource
	#detector.add_child(collision_shape)
	#
	#detector.area_entered.connect(func(area):
		#collision_occurred = true
		#print("    ✓ 动态碰撞信号触发")
	#)
	#
	#add_child(detector)
	#
	## 移动检测器穿过固定实例
	#var tween = create_tween()
	#tween.tween_property(detector, "position", Vector2(350, 300), 0.5)
	#tween.tween_callback(func():
		#test_and_print(collision_occurred, "动态移动过程中的碰撞检测")
		#
		#detector.queue_free()
		#fixed_owner.queue_free()
	#)
	#
	#await tween.finished
#
#func test_multi_instance_collision() -> void:
	#print("  - 多实例碰撞测试")
	#
	#var collision_count = 0
	#const INSTANCE_COUNT = 3
	#
	## 创建多个QuickAreaInstance
	#var instances = []
	#var owners = []
	#
	#for i in INSTANCE_COUNT:
		#var owner_node = Node.new()
		#var instance = NoNodePhysicsFactory.create_area(base_area_data, owner_node)
		#instance.set_transform(Transform2D(0, Vector2(400 + i * 50, 400)))
		#instances.append(instance)
		#owners.append(owner_node)
	#
	## 创建覆盖所有实例的检测器
	#var detector = Area2D.new()
	#detector.collision_mask = base_area_data.collision_layer
	#var collision_shape = CollisionShape2D.new()
	#collision_shape.shape = CircleShape2D.new()
	#collision_shape.shape.radius = 100
	#detector.add_child(collision_shape)
	#
	#detector.area_entered.connect(func(area):
		#collision_count += 1
	#)
	#
	#add_child(detector)
	#detector.position = Vector2(450, 400)
	#
	#await get_tree().physics_frame
	#await get_tree().physics_frame
	#
	#test_and_print(collision_count == INSTANCE_COUNT, "多实例碰撞检测正确")
	#
	## 清理
	#detector.queue_free()
	#for owner in owners:
		#owner.queue_free()
#endregion

#region 5. 边界情况测试
func test_edge_cases() -> void:
	print_rich("\n[color=cyan]5. 边界情况测试[/color]")
	
	#await test_null_data()
	await test_space_switching()
	await test_performance()

#func test_null_data() -> void:
	#print("  - 空数据测试")
	#
	## 测试空数据
	#var null_data = null
	#var owner_node = Node.new()
	#
	## 这里应该会出错，但我们测试错误处理
	#var instance = NoNodePhysicsFactory.create_area(null_data, owner_node)
	#
	## 实例应该为null或者无效
	#test_and_print(instance == null or !instance.area_rid.is_valid(), "空数据正确处理")
	#
	#if instance and instance.area_rid.is_valid():
		#owner_node.queue_free()

func test_space_switching() -> void:
	print("  - 空间切换测试")
	
	# 创建一个新的Viewport来测试不同空间
	var test_viewport = SubViewport.new()
	test_viewport.size = Vector2i(100, 100)
	var test_world = World2D.new()
	test_viewport.world_2d = test_world
	add_child(test_viewport)
	
	var owner_node = Node.new()
	var instance = NoNodePhysicsFactory.create_area(base_area_data, owner_node)
	
	# 切换到新空间
	instance.set_space(test_world.space)
	await get_tree().physics_frame
	
	var current_space = PhysicsServer2D.area_get_space(instance.area_rid)
	test_and_print(current_space == test_world.space, "空间切换成功")
	
	# 切换回原空间
	instance.set_space(get_world_2d().space)
	await get_tree().physics_frame
	
	current_space = PhysicsServer2D.area_get_space(instance.area_rid)
	test_and_print(current_space == get_world_2d().space, "空间切换回成功")
	
	test_viewport.queue_free()
	owner_node.queue_free()

func test_performance() -> void:
	print("  - 性能压力测试")
	
	const PRESSURE_COUNT = 500
	var start_time = Time.get_ticks_msec()
	
	# 快速创建大量实例
	var pressure_instances:Array[QuickAreaInstance] = []
	for i in PRESSURE_COUNT:
		var instance = NoNodePhysicsFactory.create_area(base_area_data, null)
		instance.set_transform(Transform2D(0, Vector2(randf() * 1000, randf() * 1000)))
		pressure_instances.append(instance)
	
	var creation_time = Time.get_ticks_msec() - start_time
	
	# 快速销毁
	pressure_instances.clear()
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	print("    创建 %d 个实例耗时: %d ms" % [PRESSURE_COUNT, creation_time])
	
	test_and_print(true, "请自行检查测试耗时")
#endregion

#region 工具函数
func test_and_print(is_success: bool, success_msg: String) -> void:
	if is_success:
		print_rich("    [color=green]✓ %s[/color]" % success_msg)
	else:
		print_rich("    [color=red]✗ %s[/color]" % success_msg)

func print_with_color(msg:String,color_msg:String = "white"):
	print_rich("[color=%s]%s[/color]" % [color_msg,msg])

func get_area_node(data:QuickAreaData,monitoring:bool = true,collision_mask:int = 1)->Area2D:
	var area2d := Area2D.new()
	area2d.monitorable = data.monitorable
	area2d.monitoring = monitoring
	area2d.collision_layer = data.collision_layer
	area2d.collision_mask = collision_mask
	var new_collision_node := CollisionShape2D.new()
	new_collision_node.shape = data.shape_resource
	area2d.add_child(new_collision_node)
	return area2d

#endregion
