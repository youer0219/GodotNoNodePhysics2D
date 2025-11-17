# test_instance_2d.gd
# Instance2D类的完整测试脚本
# 该脚本测试Instance2D的所有核心功能

extends Node

var instance2d:Instance2D

func _notification(what: int) -> void:
	match what:
		CanvasItem.NOTIFICATION_TRANSFORM_CHANGED:
			if instance2d:
				instance2d.set_global_invalid(true)
