extends Label

# 添加更多与物理相关的性能监视器
var monitors = [
	Performance.TIME_FPS,                  # 帧率
	Performance.PHYSICS_2D_ACTIVE_OBJECTS,  # 2D物理活动对象数
	Performance.PHYSICS_2D_COLLISION_PAIRS, # 2D物理碰撞对数
	Performance.PHYSICS_2D_ISLAND_COUNT,    # 2D物理孤岛数
]

func _ready():
	set_process(false) # 不需要在每帧都更新
	set_physics_process(true)  # 开启物理帧更新

func _physics_process(_delta):
	update_performance_data()

func update_performance_data():
	# 构建一个字符串来显示所有监视器的数据
	var output = ""
	
	for monitor in monitors:
		var value = Performance.get_monitor(monitor)
		
		# 将每个监视器的数据追加到输出字符串
		match monitor:
			Performance.TIME_FPS:
				output += "FPS: " + str(value) + "\n"
			Performance.PHYSICS_2D_ACTIVE_OBJECTS:
				output += "2D Active Objects: " + str(value) + "\n"
			Performance.PHYSICS_2D_COLLISION_PAIRS:
				output += "2D Collision Pairs: " + str(value) + "\n"
			Performance.PHYSICS_2D_ISLAND_COUNT:
				output += "2D Physics Islands: " + str(value) + "\n"
	
	# 更新标签的显示内容
	text = output
