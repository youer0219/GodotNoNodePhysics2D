extends RefCounted
class_name Instance2D

var transform: Transform2D = Transform2D.IDENTITY:set = set_transform

var position: Vector2:
	get: return transform.origin
	set(value):
		transform.origin = value
var rotation: float:
	get: return transform.get_rotation()
	set(value):
		transform = transform.rotated(value - transform.get_rotation())
var scale: Vector2:
	get: return transform.get_scale()
	set(value):
		var current = transform.get_scale()
		if current != Vector2.ZERO:
			transform = transform.scaled(value / current)

func set_transform(new_transform:Transform2D):
	transform = new_transform
