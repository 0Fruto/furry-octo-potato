extends KinematicBody2D

var slopeStop = 64

var gravity = 1000.0
export var walkSpeed = 250
export var jumpVelocity = -400
var isTochingLedder = false
var climbing = false

var velocity = Vector2()

func _ready():
	pass 

func _physics_process(delta):
	if isTochingLedder:
		if !is_on_floor() || Input.is_action_pressed("ui_up"):
			climbing = true
	
	GetInput()
	$TOS.text = str(climbing)
	if !climbing:
		velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2(0, -1), slopeStop)
	ProcessAnimation()

func ProcessAnimation():
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
		if !is_on_floor():
			$Sprite.play("Jump")
		else:
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

func GetInput():
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
		

func GetHWeight():
	return 0.2 if is_on_floor() else 0.1

func _input(event):
	if event.is_action_pressed("jump") && is_on_floor():
		velocity.y = jumpVelocity

func _on_ledders_body_exited(_body):
	isTochingLedder = false
	climbing = false


func _on_ledders_body_entered(_body):
	isTochingLedder = true
	velocity.y = 0
