extends Node2D

## 需要改进:
## 1.在GDS测试稳定后，可以考虑转为C++编写，以获取更好性能和更底层改造
## 2.更多性能测试
## 3.提供更多的调整Area的方法
## 4.area的set_transform方法疑似无效，碰撞对对数在位移一段时间后无变化
	## 未来可能设定一个node2d-instance类，但没有渲染部分

## NOTE: 目前area-instance需要在_on_test_area_2d_area_shape_entered中才能被精确发现
## Area2D似乎也会被发现，但只会发射一次area-enter信号

## 目前的碰撞对数高了也会很卡。需要管理好碰撞层级。
	## 传统物理引擎5万以上（1000个相互检测的Area）时，帧率暴降；剑柄表现明显不错，1500个没有下降
## 以及在必要时候禁用物理
	## 比如，一个作用于5个子弹的子弹影响区域，有5个子弹进来后，就禁用碰撞。
## NOTE: 区域和查询分离。仅在必要时使用区域。

@export var area_data: QuickAreaData

var area_instances: Array[QuickAreaInstance] = []

func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	var tween := create_tween().set_loops(300)
	tween.tween_callback(add_areas.bind(area_data,5)).set_delay(0.2)

func _physics_process(delta: float) -> void:
	for instance:QuickAreaInstance in area_instances:
		## TODO: 疑似失效
		var instance_transform = Transform2D(0,instance.position + Vector2(10,10) * delta)
		instance.set_transform(instance_transform)

func add_areas(data: QuickAreaData, num:int = 1, _tranfrom:Transform2D = Transform2D()) -> Array[QuickAreaInstance]:
	var areas:Array[QuickAreaInstance] = []
	for i in num:
		var instance = add_area(data,_tranfrom)
		areas.append(instance)
	return areas

func add_area(data: QuickAreaData, _tranfrom:Transform2D = Transform2D()) -> QuickAreaInstance:
	var instance = GlobalAreaManager.add_area(data, self, _tranfrom)
	#var index = area_instances.size()
	#instance.area_entered.connect(_on_area_entered.bind(index))
	area_instances.append(instance)
	return instance

# 通用区域进入处理函数
func _on_area_entered(node: Area2D, other_area_rid: RID, area_rid: RID, instance_index: int) -> void:
	print("Area instance ", instance_index, " detected area enter")
	if node:
		print("Find node name: ", node.name)
	print("area_rid: ",area_rid," find enter other_area_rid: ",other_area_rid)
	print("\n")

func _on_test_area_2d_area_entered(area: Area2D) -> void:
	print("_on_test_area_2d_area_entered area: ",area)
	print("\n")

func _on_test_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print("_on_test_area_2d_area_shape_entered: ",area_rid," ",area," ",area_shape_index," ",local_shape_index)
	print("\n")
