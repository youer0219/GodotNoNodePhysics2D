extends Instance2D
class_name RayCast2DInstance

var data:RayCast2DInstanceData

# 基本属性
var enabled: bool = true
var target_position: Vector2 = Vector2(0, 50)  # 默认向下50像素
var collision_mask: int = 1
var exclude_parent_body: bool = true
var collide_with_areas: bool = false
var collide_with_bodies: bool = true
var hit_from_inside: bool = false
var exclude_parent:bool = true

var space:RID = RID()
var exclude_parent_rid:RID = RID()

# 碰撞结果
var collided: bool = false
var against: Object = null
var against_rid: RID
var against_shape: int = 0
var collision_point: Vector2 = Vector2.ZERO
var collision_normal: Vector2 = Vector2.ZERO

# 排除列表
var exclude: Array[RID] = []

var _space_state: PhysicsDirectSpaceState2D = null

# 构造函数
func _init(
	ray_cast_data:RayCast2DInstanceData, ## Ray属性配置
	space_state: PhysicsDirectSpaceState2D,
	exclude_parent_collision_object_2d:CollisionObject2D = null ## 需要排除碰撞的“父”节点
	) -> void:
	enabled = ray_cast_data.enabled
	target_position = ray_cast_data.target_position
	collision_mask = ray_cast_data.collision_mask
	collide_with_areas = ray_cast_data.collide_with_areas
	collide_with_bodies = ray_cast_data.collide_with_bodies
	hit_from_inside = ray_cast_data.hit_from_inside
	exclude_parent = ray_cast_data.exclude_parent
	
	_space_state = space_state
	
	if exclude_parent_collision_object_2d:
		exclude_parent_rid = exclude_parent_collision_object_2d.get_rid()
		if exclude_parent:
			exclude.append(exclude_parent_rid)
