extends Area2D

var wallRotation = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta):
	global_position = get_global_mouse_position()
	$Light.color = Color(rand_range(0,32767 * 1000), rand_range(0,32767 * 1000), rand_range(0,32767 * 1000), 1)
	WallAim()

func WallAim():
	if $"/root/Game/Player".aiming and Global.castMode == "wall":
		$Cast.enabled = true
		$CastR.enabled = true
		$CastL.enabled = true
		if $Cast.is_colliding() or $CastR.is_colliding() or $CastL.is_colliding():
			$Wall.show()
			$Wall.rotation = deg2rad(wallRotation)
			
			if $Cast.is_colliding() and $CastR.is_colliding() and $CastL.is_colliding():
				#if global_position - $Cast.get_collision_point() < $CastR.get_collision_point() - global_position:
				if $Cast.get_collision_point().distance_to(global_position) < $CastR.get_collision_point().distance_to(global_position) and $Cast.get_collision_point().distance_to(global_position) < $CastL.get_collision_point().distance_to(global_position):
					$Wall.global_position = $Cast.get_collision_point()
					wallRotation = 0
				elif $CastR.get_collision_point().distance_to(global_position) < $Cast.get_collision_point().distance_to(global_position) and $CastR.get_collision_point().distance_to(global_position) < $CastL.get_collision_point().distance_to(global_position):
					$Wall.global_position = $CastR.get_collision_point()
					wallRotation = -90
				elif $CastL.get_collision_point().distance_to(global_position) < $Cast.get_collision_point().distance_to(global_position) and $CastL.get_collision_point().distance_to(global_position) < $CastR.get_collision_point().distance_to(global_position):
					$Wall.global_position = $CastL.get_collision_point()
					wallRotation = 90
			
			elif $Cast.is_colliding() and $CastR.is_colliding() and !$CastL.is_colliding():
				#if global_position - $Cast.get_collision_point() < $CastR.get_collision_point() - global_position:
				if $Cast.get_collision_point().distance_to(global_position) < $CastR.get_collision_point().distance_to(global_position):
					$Wall.global_position = $Cast.get_collision_point()
					wallRotation = 0
				else:
					$Wall.global_position = $CastR.get_collision_point()
					wallRotation = -90
			
			elif $Cast.is_colliding() and $CastL.is_colliding() and !$CastR.is_colliding():
				#if global_position - $Cast.get_collision_point() < $CastR.get_collision_point() - global_position:
				if $Cast.get_collision_point().distance_to(global_position) < $CastL.get_collision_point().distance_to(global_position):
					$Wall.global_position = $Cast.get_collision_point()
					wallRotation = 0
				else:
					$Wall.global_position = $CastL.get_collision_point()
					wallRotation = 90
			
			elif $CastL.is_colliding() and $CastR.is_colliding() and !$Cast.is_colliding():
				#if global_position - $Cast.get_collision_point() < $CastR.get_collision_point() - global_position:
				if $CastL.get_collision_point().distance_to(global_position) < $CastR.get_collision_point().distance_to(global_position):
					$Wall.global_position = $CastL.get_collision_point()
					wallRotation = 90
				else:
					$Wall.global_position = $CastR.get_collision_point()
					wallRotation = -90
			
			elif $CastR.is_colliding() and !$Cast.is_colliding() and !$CastL.is_colliding():
				$Wall.global_position = $CastR.get_collision_point()
				wallRotation = -90
			elif $CastL.is_colliding() and !$Cast.is_colliding() and !$CastR.is_colliding():
				$Wall.global_position = $CastR.get_collision_point()
				wallRotation = 90
			elif $Cast.is_colliding() and !$CastR.is_colliding() and !$CastR.is_colliding():
				$Wall.global_position = $Cast.get_collision_point()
				wallRotation = 0
		else:
			$Wall.hide()
	else:
		$Cast.enabled = false
		$Wall.hide()
