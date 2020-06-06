extends Area2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta):
	global_position = get_global_mouse_position()
	$Light.color = Color(rand_range(0,32767), rand_range(0,32767), rand_range(0,32767), 1)
	WallAim()

func WallAim():
	if $"/root/Game/Player".aiming:
		$Cast.enabled = true
		if $Cast.is_colliding():
			$Wall.show()
			$Wall.global_position = $Cast.get_collision_point()
			if Input.is_action_just_pressed("attack"):
				$"/root/Game".BuildWall()
		else:
			$Wall.hide()
	else:
		$Cast.enabled = false
		$Wall.hide()
