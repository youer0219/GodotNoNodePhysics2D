@tool
extends EditorPlugin

const GlobalAreaManagerName = "GlobalAreaManager"

func _enter_tree():
	add_autoload_singleton(GlobalAreaManagerName, "res://addons/no_node_physics_2d/global_area_manager/global_area_manager.gd")

func _exit_tree():
	remove_autoload_singleton(GlobalAreaManagerName)
