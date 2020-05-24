extends KinematicBody2D

export var sideJumpAcceleration = 300
export var slopeStop = 64
export var gravity = 1000.0
export var walkSpeed = 170
export var jumpVelocity = -400
export var jumpTimerGoal = 2
export var slowTimeMod = 0.009
var jumpTimer = 0

var velocity = Vector2()

var isTochingLedder = false
var climbing = false
var respawnPos
var casting = false
var hatTimer = 0
var hatTimerGoal = 10
var tossingHat = false
var direction = 1

var aim = false
var aimedOnEnemy = false
export var rotatingRayRadNormal = 0.1
var rotatingRayRad = 0.1


func _ready():
	jumpTimer = jumpTimerGoal
	$"../Light2D/AnimationPlayer".current_animation = "Light"
	respawnPos = global_position

func _process(delta):
	Aim()
	if hatTimer < hatTimerGoal:
		if velocity.x == 0:
			hatTimer += delta
		else:
			hatTimer = 0
	if hatTimer >= hatTimerGoal && velocity.x == 0:
		if !$"Middle ray".is_colliding():
			$Sprite.play("Tossing a hat")
			hatTimer = 0
			tossingHat = true
	if jumpTimer < jumpTimerGoal:
		jumpTimer += delta * 10
	if isTochingLedder:
		if !is_on_floor() || Input.is_action_pressed("ui_up"):
			climbing = true
	else:
		climbing = false
	ProcessAnimation()
	$TOS.text = str(round(hatTimer*10)/10)
	

func _physics_process(delta):
	CheckJump()
	GetInput()
	if !climbing:
		velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2(0, -1), slopeStop)









func ProcessAnimation():
	if !casting && !tossingHat:
		
		if climbing:
			if Input.is_action_pressed("ui_up"):
				$Sprite.play("Climbing")
			if Input.is_action_pressed("ui_down"):
				$Sprite.play("Climbing")
			if !is_on_floor():
				if !Input.is_action_pressed("ui_up") && !Input.is_action_pressed("ui_down"):
					$Sprite.play("Climbing")
					$Sprite.stop()
			else: if Input.is_action_pressed("ui_down"):
				$Sprite.play("Idle")
				climbing = false
		else:
			if !aim:
				if is_on_floor():
					if !Input.is_action_pressed("ui_right") && !Input.is_action_pressed("ui_left"):
						if Input.is_action_pressed("ui_down"):
							$Sprite.play("Crouch")
						else:
							$Sprite.play("Idle")
				
				if Input.is_action_pressed("ui_right") || Input.is_action_pressed("ui_left"):
					if is_on_floor():
						$Sprite.play("Run")
				else: if velocity.x == 0:
					if Input.is_action_pressed("ui_down"):
						$Sprite.play("Crouch")
					else:
						$Sprite.play("Idle")
			
			if !is_on_floor():
				if Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_right"):
					$Sprite.play("Side Jump")
				else:
					$Sprite.play("Jump")
		
		if Input.is_action_just_pressed("attack") && is_on_floor():
			hatTimer = 0
			velocity.x = 0
			$Sprite.play("Fireball")
			casting = true
		if Input.is_action_just_pressed("wall") && is_on_floor():
			hatTimer = 0
			$Sprite.play("Set wall")
			casting = true
			velocity.x = 0

func GetInput():
	if Input.is_action_just_pressed("restart"):
		hatTimer = 0
		global_position = respawnPos
	if !casting && !tossingHat && !aim:
		if Input.is_action_just_pressed("ui_down") && is_on_floor():
			position += Vector2(0, 1)
			#velocity.y = 1000
		var moveDirection = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
		velocity.x = lerp(velocity.x, walkSpeed * moveDirection, GetHWeight())
		if moveDirection != 0:
			$Sprite.scale.x = moveDirection
			direction = moveDirection
		if moveDirection < 0:
			if $"Middle ray".cast_to.x > 0:
				$"Middle ray".cast_to.x = $"Middle ray".cast_to.x * -1
				$"Short ray".cast_to.x = $"Short ray".cast_to.x * -1
				$"Long ray".cast_to.x = $"Long ray".cast_to.x * -1
		if moveDirection > 0:
			if $"Middle ray".cast_to.x < 0:
				$"Middle ray".cast_to.x = $"Middle ray".cast_to.x * -1
				$"Short ray".cast_to.x = $"Short ray".cast_to.x * -1
				$"Long ray".cast_to.x = $"Long ray".cast_to.x * -1
		if climbing:
			if Input.is_action_pressed("ui_up"):
				velocity.y = -100
			else:
				if Input.is_action_pressed("ui_down"):
					velocity.y = 100
				else:
					velocity.y = 0

func Aim():
	rotatingRayRad = rotatingRayRadNormal
	if Input.is_action_pressed("aim"):
		aim = true
		$"Long ray".enabled = true
		Engine.time_scale = slowTimeMod
		$MainCamera.zoom = Vector2(0.4, 0.4)
		if $"Long ray".rotation_degrees < -90 || $"Long ray".rotation_degrees > 90:
			$Sprite.scale.x = direction * -1
		else:
			$Sprite.scale.x = direction
		if $"Long ray".is_colliding():
			$Aim.show()
			$Aim.set_point_position(0, Vector2(0,0))
			$Aim.set_point_position(1, $"Long ray".get_collision_point() - global_position)
			if $"Long ray".get_collider().name == "Enemy":
				aimedOnEnemy = true
				$Aim.default_color = Color(0, 1, 0, 1)
				rotatingRayRad = rotatingRayRadNormal / 4
			else:
				aimedOnEnemy = false
				$Aim.default_color = Color(1, 0, 0, 1)
				rotatingRayRad = rotatingRayRadNormal
		else:
			aimedOnEnemy = false
			$Aim.hide()
		if Input.is_action_pressed("ui_up"):
			if $"Long ray".cast_to.x > 0:
				$"Long ray".rotate(-rotatingRayRad)
			if $"Long ray".cast_to.x < 0:
				$"Long ray".rotate(rotatingRayRad)
		if Input.is_action_pressed("ui_down"):
			if $"Long ray".cast_to.x > 0:
				$"Long ray".rotate(rotatingRayRad)
			if $"Long ray".cast_to.x < 0:
				$"Long ray".rotate(-rotatingRayRad)
		if is_on_floor():
			velocity.x = 0
			if !casting && !tossingHat:
				$Sprite.play("Idle")
	else:
		aim = false
		$MainCamera.zoom = Vector2(0.2, 0.2)
		$"Long ray".enabled = false
		$"Long ray".rotation = 0
		$Aim.hide()
		Engine.time_scale = 1.0
		direction = $Sprite.scale.x
		if ($"Long ray".cast_to.x > 0 && direction < 0) || ($"Long ray".cast_to.x < 0 && direction > 0):
			$"Long ray".cast_to.x = -$"Long ray".cast_to.x

func kickback(force):
	if $"Long ray".cast_to.x < 0:
		force = -force
	velocity = Vector2(cos($"Long ray".rotation) * -force, sin($"Long ray".rotation) * -force)

func CheckJump():
	if jumpTimer < jumpTimerGoal:
		if is_on_floor():
			velocity.y = jumpVelocity
			if Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_right"):
				$Sprite.play("Side Jump")
				velocity.x += sideJumpAcceleration * $Sprite.scale.x
			else:
				$Sprite.play("Jump")

func GetHWeight():
	return 0.2 if is_on_floor() else 0.1

func _input(event):
	if !casting && !aim:
		if event.is_action_pressed("jump"):
			jumpTimer = 0

func _on_ledders_body_exited(_body):
	isTochingLedder = false
	climbing = false

func _on_ledders_body_entered(_body):
	isTochingLedder = true
	velocity.y = 0


func _on_Sprite_animation_finished():
	casting = false
	tossingHat = false
