extends Node2D


@export var base_area_data:QuickAreaData

func _ready() -> void:
	base_test()

func base_test():
	## 实例创建与销毁
	var data := base_area_data.duplicate()
	# QuickAreaInstance.new(data,self) 这个的生成是否应该强制使用全局管理呢？
	var instance := GlobalAreaManager.create_area(data,self)
	var area_rid := instance.area_rid
	
	var finded_instance := GlobalAreaManager.get_area_instance(area_rid)
	if finded_instance and finded_instance.get_owner() == self:
		print("OK")
	
	# 直接将instance设置为null无法销毁instance，因为全局管理中其被设置为强引用
	# 需要将其改为弱引用
	
	pass
