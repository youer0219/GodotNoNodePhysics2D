# AreaData 作为资源，存储共享属性
class_name AreaData
extends Resource

@export var shape_resource: Shape2D
@export_flags_2d_physics var collision_layer: int = 1
@export_flags_2d_physics var collision_mask: int = 1
@export var monitoring: bool = true
@export var monitorable: bool = true

static func make_circle(radius: float) -> AreaData:
	var shape = CircleShape2D.new()
	shape.radius = radius
	var area_data = AreaData.new()
	area_data.shape_resource = shape
	return area_data

static func make_rectangle(size: Vector2) -> AreaData:
	var shape = RectangleShape2D.new()
	shape.size = size
	var area_data = AreaData.new()
	area_data.shape_resource = shape
	return area_data

static func make_capsule(radius: float, height: float) -> AreaData:
	var shape = CapsuleShape2D.new()
	shape.radius = radius
	shape.height = height
	var area_data = AreaData.new()
	area_data.shape_resource = shape
	return area_data

static func make_convex_polygon(points: PackedVector2Array) -> AreaData:
	var shape = ConvexPolygonShape2D.new()
	shape.points = points
	var area_data = AreaData.new()
	area_data.shape_resource = shape
	return area_data

static func make_concave_polygon(segments: PackedVector2Array) -> AreaData:
	var shape = ConcavePolygonShape2D.new()
	shape.segments = segments
	var area_data = AreaData.new()
	area_data.shape_resource = shape
	return area_data
