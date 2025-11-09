extends Node2D


@export var base_area_data:QuickAreaData

func _ready() -> void:
	base_test()
	test_collision()

func base_test():
	## 实例创建测试
	var data := base_area_data.duplicate()
	var test_owner_node:Node = Node.new()
	# TODO: QuickAreaInstance.new(data,self) 这个的生成是否应该强制使用全局管理呢？
	var instance := GlobalAreaManager.create_area(data,test_owner_node)
	var area_rid := instance.area_rid
	var shape_rid := instance.shape_rid
	
	var finded_instance := GlobalAreaManager.get_area_instance(area_rid)
	test_and_print((finded_instance \
	and finded_instance.shape_rid == shape_rid),
	"成功创建实例并从全局管理中获取正确实例")
	
	## 拥有者获取测试
	var finded_owner := finded_instance.get_owner()
	test_and_print(finded_owner and finded_owner == test_owner_node \
	and finded_owner == GlobalAreaManager.get_area_owner(area_rid),
	"成功获取拥有者实例")
	
	## 拥有者弱引用测试
	finded_owner.free()
	test_and_print(finded_instance.get_owner() == null \
	and GlobalAreaManager.get_area_owner(area_rid) == null,
	"销毁拥有者节点后，拥有者弱引用自动失效")
	
	## 实例销毁测试
	instance = null
	finded_instance = null
	finded_instance = GlobalAreaManager.get_area_instance(area_rid)
	test_and_print(finded_instance == null,
	"实例引用销毁后自动注销其在全局管理中的注册")
	
	## 判断area-rid和shape-rid被正确释放 注意会出现两个报错
	test_and_print(PhysicsServer2D.area_get_shape_count(area_rid) == -1,
	"实例自动销毁后，原先的area_rid无法使用")
	test_and_print(PhysicsServer2D.shape_get_data(shape_rid) == null,
	"实例自动销毁后，原先的shape-rid无法使用")
	
	print("\n")

## TODO: Node2D部分还缺少测试。感觉涉及部分代码改动，如将position改为global-potision，暂时搁置

func test_collision():
	var data := base_area_data.duplicate()
	var base_instance := GlobalAreaManager.create_area(data,self)
	# TODO: 这里的 self_area_rid 的必要性存疑
	base_instance.area_entered.connect(
		func(_area: Area2D, other_area_rid: RID, _self_area_rid: RID):
			print("area_entered  other_area_rid: ",other_area_rid)
			var other_area_instance := GlobalAreaManager.get_area_instance(other_area_rid)
			print("area_entered  other_area_instance: ",other_area_instance)
	)
	base_instance.area_exited.connect(
		func(_area: Area2D, other_area_rid: RID, _self_area_rid: RID):
			print("area_exited  other_area_rid: ",other_area_rid)
			var other_area_instance := GlobalAreaManager.get_area_instance(other_area_rid)
			print("area_exited  other_area_instance: ",other_area_instance)
	)
	
	## Instance-Instance
	var new_instance := GlobalAreaManager.create_area(data,self)
	print("new_instance_area_rid: ",new_instance.area_rid)
	print("new_instance: ",new_instance)
	await get_tree().physics_frame
	await get_tree().physics_frame  ## TODO:需要等待两帧才可触发碰撞，原理存疑
	new_instance = null # 自动回收销毁
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	print_rich("[color=yellow]%s[/color]" % "自行检查信号输出和new_instance的属性是否匹配")
	print("\n")

func test_and_print(is_success:bool,success_msg:String):
	if is_success:
		print_rich("[color=green]%s[/color]" % success_msg)
	else:
		print_rich("[color=red][b]NOT %s[/b][/color]" % success_msg)
