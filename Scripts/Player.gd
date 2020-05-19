extends KinematicBody2D

var gravity = 5.0
export var walkSpeed = 200
export var jumpForce = 1000

var velocity = Vector2()

func _ready():
	pass 

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity
	 
	if is_on_floor() and !Input.is_action_pressed("jump"):
		velocity.y = 0
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jumpForce

	if Input.is_action_pressed("ui_left"):
		velocity.x = -walkSpeed
	elif Input.is_action_pressed("ui_right"):
		velocity.x =  walkSpeed
	else:
		velocity.x = 0
	
	move_and_slide(velocity, Vector2(0, -1))
