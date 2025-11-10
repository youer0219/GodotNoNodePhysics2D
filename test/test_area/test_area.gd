extends Node2D

@export var base_area_data:QuickAreaData

func _ready() -> void:
	base_test()
	#test_collision()

func base_test():
	## 实例创建测试
	var data := base_area_data.duplicate()
	var test_owner_node:Node = Node.new()
	# TODO: QuickAreaInstance.new(data,self) 这个的生成是否应该强制使用全局管理呢？
	var instance := GlobalAreaManager.create_area(data,test_owner_node)
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
	
	var finded_instance = GlobalAreaManager.get_instance_by_rid(area_rid)
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

## TODO: Node2D部分还缺少测试。感觉涉及部分代码改动，如将position改为global-potision，暂时搁置

func test_and_print(is_success:bool,success_msg:String):
	if is_success:
		print_rich("[color=green]%s[/color]" % success_msg)
	else:
		print_rich("[color=red][b]NOT %s[/b][/color]" % success_msg)

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
