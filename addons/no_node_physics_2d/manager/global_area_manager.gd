extends Area2D

var instances: Dictionary = {}  # RID -> QuickAreaInstance
var space: RID
var instance_pool: Array[QuickAreaInstance] = []

@export var use_pool: bool = true:
	set(value):
		use_pool = value
		if not use_pool:
			clear_pool_instances()

func _ready() -> void:
	monitorable = false
	monitoring = false
	collision_layer = 0
	collision_mask = 0
	input_pickable = false
	
	space = get_world_2d().space

func add_area(area_data: QuickAreaData, area_owner: Object, area_transform: Transform2D = Transform2D()) -> QuickAreaInstance:
	var instance: QuickAreaInstance
	if use_pool and instance_pool.size() > 0:
		instance = instance_pool.pop_back() as QuickAreaInstance
		instance.setup(area_data, area_owner, area_transform, space)
	else:
		instance = QuickAreaInstance.new(area_data, area_owner, area_transform, space)
		PhysicsServer2D.area_attach_object_instance_id(instance.area_rid, get_instance_id())
	
	instances[instance.area_rid] = instance
	return instance

func remove_area(area_rid: RID) -> void:
	if not instances.has(area_rid):
		return
	var instance: QuickAreaInstance = instances[area_rid]
	
	if use_pool:
		instance.clear_for_pool()
		instance_pool.append(instance)
	else:
		instance.free_rids()
	
	instances.erase(area_rid)

func clear_active_instances():
	for instance:QuickAreaInstance in instances.values():
		instance.free_rids()
	instances.clear()

func clear_pool_instances():
	for inst in instance_pool:
		inst.free_rids()
	instance_pool.clear()

func clear() -> void:
	clear_active_instances()
	clear_pool_instances()

func get_area_owner(area_rid:RID)->Object:
	if instances.has(area_rid):
		return instances[area_rid].get_owner()
	return null

func set_area_transform(area_rid: RID, xform: Transform2D) -> void:
	if instances.has(area_rid):
		instances[area_rid].set_transform(xform)
