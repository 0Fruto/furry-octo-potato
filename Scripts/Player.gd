extends KinematicBody2D

export var slopeStop = 64
export var gravity = 1000.0
export var walkSpeed = 250
export var jumpVelocity = -400
export var jumpTimerGoal = 2
var jumpTimer = 0

var velocity = Vector2()

var isTochingLedder = false
var climbing = false
var respawnPos
var casting = false


func _ready():
	jumpTimer = jumpTimerGoal
	$"../Light2D/AnimationPlayer".current_animation = "Light"
	respawnPos = global_position

func _process(delta):
	if jumpTimer < jumpTimerGoal:
		jumpTimer += delta * 10
	if isTochingLedder:
		if !is_on_floor() || Input.is_action_pressed("ui_up"):
			climbing = true
	else:
		climbing = false
	ProcessAnimation()
	$TOS.text = str(jumpTimer)
	$TOS2.text = str(is_on_floor())

func _physics_process(delta):
	CheckJump()
	GetInput()
	if !climbing:
		velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2(0, -1), slopeStop)









func ProcessAnimation():
	if !casting:
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
				$Sprite.play("Jump")
		
		if Input.is_action_just_pressed("attack"):
			$Sprite.play("Fireball")
			casting = true
			velocity.x = 0
		if Input.is_action_just_pressed("wall") && is_on_floor():
			$Sprite.play("Set wall")
			casting = true
			velocity.x = 0

func GetInput():
	if Input.is_action_just_pressed("restart"):
		global_position = respawnPos
	if !casting:
		if Input.is_action_just_pressed("ui_down") && is_on_floor():
			position += Vector2(0, 1)
			#velocity.y = 1000
		var moveDirection = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
		velocity.x = lerp(velocity.x, walkSpeed * moveDirection, GetHWeight())
		if moveDirection != 0:
			$Sprite.scale.x = moveDirection
		if climbing:
			if Input.is_action_pressed("ui_up"):
				velocity.y = -100
			else:
				if Input.is_action_pressed("ui_down"):
					velocity.y = 100
				else:
					velocity.y = 0

func CheckJump():
	if jumpTimer < jumpTimerGoal:
		if is_on_floor():
			velocity.y = jumpVelocity
			$Sprite.play("Jump")

func GetHWeight():
	return 0.2 if is_on_floor() else 0.1

func _input(event):
	if !casting:
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
