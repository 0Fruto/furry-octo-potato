extends Line2D

export var length = 20

func _ready():
	pass

func _process(delta):
	global_position = Vector2(0,0)
	add_point($"..".global_position)
	while get_point_count() > length:
		remove_point(0)
