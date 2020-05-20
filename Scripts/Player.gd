extends KinematicBody2D

var slopeStop = 64

var gravity = 1000.0
export var walkSpeed = 250
export var jumpVelocity = -400


var velocity = Vector2()

func _ready():
	pass 

func _physics_process(delta):
	GetInput()
	velocity.y += gravity * delta
	
	
	velocity = move_and_slide(velocity, Vector2(0, -1), slopeStop)

func GetInput():
	var moveDirection = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
	velocity.x = lerp(velocity.x, walkSpeed * moveDirection, GetHWeight())
	#if moveDirection != 0:
	#	$Body.scale.x = moveDirection

func GetHWeight():
	return 0.2 if is_on_floor() else 0.1

func _input(event):
	if event.is_action_pressed("jump") && is_on_floor():
		velocity.y = jumpVelocity
