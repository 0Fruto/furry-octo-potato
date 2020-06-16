extends Line2D

export var length = 20

func _ready():
	pass

func _process(_delta):
	global_position = $"/root/Game/Player".global_position
	add_point($"..".position)
	while get_point_count() > length:
		remove_point(0)
