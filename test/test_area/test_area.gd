extends Node2D


@export var base_area_data:QuickAreaData

func _ready() -> void:
	base_test()

func base_test():
	## 实例创建测试
	var data := base_area_data.duplicate()
	# TODO: QuickAreaInstance.new(data,self) 这个的生成是否应该强制使用全局管理呢？
	var instance := GlobalAreaManager.create_area(data,self)
	var area_rid := instance.area_rid
	var shape_rid := instance.shape_rid
	
	var finded_instance := GlobalAreaManager.get_area_instance(area_rid)
	if finded_instance and finded_instance.get_owner() == self and finded_instance.shape_rid == shape_rid:
		print("OK")
	
	## 实例销毁测试
	instance = null
	finded_instance = null
	finded_instance = GlobalAreaManager.get_area_instance(area_rid)
	if finded_instance and finded_instance.get_owner() == self:
		print("NOT OK")
	
	## 判断area-rid和shape-rid被正确释放 注意报错
	var shape_count := PhysicsServer2D.area_get_shape_count(area_rid)
	print(shape_count == -1)
	var shape_data = PhysicsServer2D.shape_get_data(shape_rid)
	print(shape_data == null)
