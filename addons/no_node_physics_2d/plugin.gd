@tool
extends EditorPlugin

const NoNodePhysicsFactoryName = "NoNodePhysicsFactory"

func _enter_tree():
	add_autoload_singleton(NoNodePhysicsFactoryName, "res://addons/no_node_physics_2d/no_node_physics_factory.gd")

func _exit_tree():
	remove_autoload_singleton(NoNodePhysicsFactoryName)
