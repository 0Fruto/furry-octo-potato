extends KinematicBody2D

export var health = 100
export var mana = 100
var manaDisplay = 100

export var sideJumpAcceleration = 300
export var slopeStop = 64
export var gravity = 1000.0
export var walkSpeed = 170
export var jumpVelocity = -400
export var jumpTimerGoal = 2
var jumpTimer = 0

var velocity = Vector2()

var casting = false
var hatTimer = 0
var hatTimerGoal = 10
var tossingHat = false
var direction = 1
var firstAnimL = true
var landing = false

onready var pauseManager = $MainCamera/Pause

var cursorRot

export var rotatingRayRadNormal = 0.1
var rotatingRayRad = 0.1


func _ready():
	jumpTimer = jumpTimerGoal
	$"../Light2D/AnimationPlayer".current_animation = "Light"

func _process(delta):
	var rotDifference = get_global_mouse_position() - global_position
	cursorRot = atan2(rotDifference.y, rotDifference.x)
	HatAnimationProcess(delta)
	if jumpTimer < jumpTimerGoal:
		jumpTimer += delta * 10
	
	ProcessAnimation()
	#$TOS.text = str(round(hatTimer*10)/10)
	if mana < 100: mana += delta
	ManaProcess(delta)
	$"MainCamera/Mana".value = manaDisplay
	$"MainCamera/Health".value = health

func _physics_process(delta):
	CheckJump()
	GetInput()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2(0, -1), slopeStop)









func ProcessAnimation():
		if Input.is_action_pressed("ui_right") || Input.is_action_pressed("ui_left"):
			if is_on_floor():
				$Sprite.play("Run")
		
		if is_on_floor():
			if firstAnimL:
				if !landing:
					firstAnimL = false
					$Sprite.play("Landing")
					landing = true
			elif !landing and !Input.is_action_pressed("ui_right") && !Input.is_action_pressed("ui_left") and velocity.x == 0:
				$Sprite.play("Idle")
			elif !landing and !Input.is_action_pressed("ui_right") && !Input.is_action_pressed("ui_left") and velocity.x != 0:
				$Sprite.play("PreIdle")
		
		elif !is_on_floor():
			#if Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_right"):
				#$Sprite.play("Side Jump")
			#else:
			#if !jumpStart:
				if velocity.y >= 0:
					$Sprite.play("Falling")
					firstAnimL = true 
				elif velocity.y < 0:
					$Sprite.play("JumpUp")
					firstAnimL = true
		
		if Input.is_action_just_pressed("attack") && is_on_floor() && mana > 10:
			hatTimer = 0
			velocity.x = 0
			#$Sprite.play("Fireball")
			casting = true
		if Input.is_action_just_pressed("wall") && is_on_floor() && mana > 10:
			hatTimer = 0
			#$Sprite.play("Set wall")
			casting = true
			velocity.x = 0

func GetInput():
	if Input.is_action_just_pressed("ui_cancel"):
		pauseManager.Pause()
	if Input.is_action_just_pressed("restart"):
		pauseManager.Restart()
	if !casting:
		#if Input.is_action_just_pressed("ui_down") && is_on_floor():
			#position += Vector2(0, 1)
			#velocity.y = 1000
		var moveDirection = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
		velocity.x = lerp(velocity.x, walkSpeed * moveDirection, GetHWeight())
		if moveDirection != 0:
			$Sprite.scale.x = moveDirection

func kickback(force):
	velocity = Vector2(cos(cursorRot) * -force, sin(cursorRot) * -force)

func CheckJump():
	if jumpTimer < jumpTimerGoal:
		if is_on_floor():
			velocity.y = jumpVelocity
			if Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_right"):
				#$Sprite.play("Side Jump")
				velocity.x += sideJumpAcceleration * $Sprite.scale.x
				#jumpStart = true
			#else:
				#$Sprite.play("Jump")
				#jumpStart = true

func GetHWeight():
	return 0.2 if is_on_floor() else 0.1

func _input(event):
	if !casting:
		if event.is_action_pressed("jump"):
			jumpTimer = 0

func ManaProcess(delta):
	if manaDisplay < mana + delta * 20:manaDisplay += delta * 20
	elif manaDisplay < mana + delta * 10:manaDisplay += delta * 10
	elif manaDisplay < mana + delta * 5:manaDisplay += delta * 5
	elif manaDisplay < mana + delta * 2:manaDisplay += delta * 2
	elif manaDisplay < mana + delta / 2:manaDisplay += delta / 2
	
	if manaDisplay > mana - delta * 20:manaDisplay -= delta * 20
	elif manaDisplay > mana - delta * 10:manaDisplay -= delta * 10
	elif manaDisplay > mana - delta * 5:manaDisplay -= delta * 5
	elif manaDisplay > mana - delta * 2:manaDisplay -= delta * 2
	elif manaDisplay > mana - delta / 2:manaDisplay -= delta / 2

func _on_Sprite_animation_finished():
	casting = false
	tossingHat = false
	if is_on_floor():
		landing = false

func HatAnimationProcess(delta):
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
