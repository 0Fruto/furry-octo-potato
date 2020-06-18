extends KinematicBody2D

export var health = 100
export var mana = 100
var manaDisplay = 100

export var sideJumpAcceleration = 650
export var slopeStop = 64
export var gravity = 1000.0
export var walkSpeed = 250
export var jumpVelocity = -350
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
var sideJump = false
var aiming = true
var climbing = false
var climbingUp = false
var dontClimb = 10

var fly = false
var flyTimer = 100

var alive = true
var highDeath = false

onready var pauseManager = $MainCamera/Pause

var loadFakeBottle
var fakeBottleCounter = 0

var cursorRot

export var rotatingRayRadNormal = 0.1
var rotatingRayRad = 0.1


func _ready():
	ColToIdle()
	#Engine.time_scale = 0.5
	jumpTimer = jumpTimerGoal
	$"../Light2D/AnimationPlayer".current_animation = "Light"
	loadFakeBottle = preload("res://Prefabs/FakeBottle.tscn")

func _process(delta):
	if alive:
		if aiming:
			$Sprite.play("Walking")
			walkSpeed = 70
		else:
			walkSpeed = 250
		if health <= 0:
			Die()
		FlyProcess()
		BottleAim()
		var rotDifference = get_global_mouse_position() - global_position
		cursorRot = atan2(rotDifference.y, rotDifference.x)
		HatAnimationProcess(delta)
		if jumpTimer < jumpTimerGoal:
			jumpTimer += delta * 10
		
		ProcessAnimation()
		$TOS.text = str(velocity.y)
		$TOS2.text = str(fakeBottleCounter)
		if mana < 100: mana += delta
		ManaProcess(delta)
		$"MainCamera/Mana".value = manaDisplay
		$"MainCamera/Health".value = health
		CollapseProcces()

func _physics_process(delta):
	Climbing()
	CheckHighDeath()
	if alive:
		CheckJump()
		GetInput()
	if !fly and !climbing:
		velocity.y += gravity * delta
	if !alive:
		velocity.x = 0
	velocity = move_and_slide(velocity, Vector2(0, -1), slopeStop)









func ProcessAnimation():
	if !fly and !sideJump and alive:
		if Input.is_action_pressed("ui_right") || Input.is_action_pressed("ui_left"):
			if is_on_floor() and !firstAnimL:
				if !aiming:
					$Sprite.play("Run")
					ColToRun()
				else:
					$Sprite.play("Walking")
		
		if is_on_floor():
			if firstAnimL:
				if !landing:
					landing = true
					$Sprite.play("Landing")
					yield($Sprite, "animation_finished")
					ColToIdle()
					landing = false
					firstAnimL = false
			elif !landing and (velocity.x == 0) or (!Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right")) or Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_right"):
				if !IsOnEdge():
					$Sprite.play("Idle")
					ColToIdle()
		
		elif !is_on_floor() and !climbing:
			if !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right"):
				if velocity.y >= 0:
					$Sprite.play("Falling")
					ColToIdle()
					firstAnimL = true 
				elif velocity.y < 0:
					$Sprite.play("JumpUp")
					ColToIdle()
					firstAnimL = true
			elif Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
				if velocity.y >= 40:
					$Sprite.play("Side fall")
					ColToRun()
					firstAnimL = true
				elif velocity.y <= 40 and velocity.y >= -40:
					$Sprite.play("Side mid")
					ColToRun()
					firstAnimL = true
				elif velocity.y < -40:
					$Sprite.play("Side up")
					ColToRun()
		
		if Input.is_action_just_pressed("attack") && is_on_floor() && mana > 10 && !aiming:
			hatTimer = 0
			velocity.x = 0
			#$Sprite.play("Fireball")
			#casting = true
		if Input.is_action_just_pressed("wall") && is_on_floor() && mana > 10:
			hatTimer = 0
			#$Sprite.play("Set wall")
			#casting = true
			velocity.x = 0

func GetInput():
	if alive:
		if Input.is_action_just_pressed("ui_cancel"):
			pauseManager.Pause()
		if Input.is_action_just_pressed("restart"):
			pauseManager.Restart()
		if !climbing:
			if Input.is_action_pressed("fly"):
				if mana > 1:
					fly = true
					if fly:
						mana -= 0.5
				else:
					fly = false
			elif !Input.is_action_pressed("fly"):
				fly = false
			#if Input.is_action_just_pressed("ui_down") && is_on_floor():
				#position += Vector2(0, 1)
				#velocity.y = 1000
			var moveDirection = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
			if !fly:
				velocity.x = lerp(velocity.x, walkSpeed * moveDirection, GetHWeight())
			else:
				velocity.x = lerp(velocity.x, walkSpeed * moveDirection * 3, GetHWeight())
				velocity.y = lerp(velocity.y, walkSpeed * (-int(Input.is_action_pressed("ui_up")) + int(Input.is_action_pressed("ui_down"))) * 3, GetHWeight())
			if moveDirection != 0:
				$ColliderRun.scale.x = moveDirection
				$Collider.position.x = 5 * moveDirection
				$Sprite.scale.x = moveDirection
				$"Upper ray".position.x = 16 * $Sprite.scale.x
				$"Upper ray".cast_to.x = 30 * $Sprite.scale.x
				$"Short ray".cast_to.x = 30 * $Sprite.scale.x
				if moveDirection == 1:
					$Right.position.x = 15
					$Left.position.x = -5
				elif moveDirection == -1:
					$Right.position.x = 5
					$Left.position.x = -15

func kickback(force):
	if !fly:
		if cursorRot:
			velocity = Vector2(cos(cursorRot) * -force, sin(cursorRot) * -force)

func CheckJump():
	#if (jumpTimer < jumpTimerGoal or Input.is_action_pressed("jump")) and alive:
	if jumpTimer < jumpTimerGoal and alive:
		if is_on_floor():
			jumpTimer = jumpTimerGoal
			if Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_right"):
				$Sprite.play("Side Jump")
				ColToRun()
				sideJump = true
				yield($Sprite, "animation_finished")
				velocity.y = jumpVelocity
				velocity.x = sideJumpAcceleration * $Sprite.scale.x
				$Sprite.play("Side up")
				yield(get_tree().create_timer(0.1), "timeout")
				sideJump = false
			else:
				$Sprite.play("Jump")
				velocity.y = jumpVelocity
				sideJump = false
			

func GetHWeight():
	return 0.2 #if is_on_floor() else 0.08

func _input(event):
	if !casting and !fly and alive:
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

func FlyProcess():
	var rock = $Rock
	if fly:
		rock.show()
		if rock.offset.y > 0:
			rock.offset.y -= 100
		if rock.offset.y < 30:
			rock.offset.y = 0
		$Sprite.play("Idle")
		ColToIdle()
	else:
		rock.hide()
		rock.offset.y = 300
		flyTimer = 100

func Damage(damage):
	health -= damage
	$"MainCamera/Health".value = health

func ColToRun():
	$Collider.disabled = true
	$ColliderRun.disabled = false
	
func ColToIdle():
	$Collider.disabled = false
	$ColliderRun.disabled = true

func Die():
	alive = false
	velocity.x = 0
	if highDeath:
		$Sprite.play("HighDeath")
	else:
		$Sprite.play("Death")
	yield($Sprite, "animation_finished")
	$MainCamera/Death.Pause()

func CheckHighDeath():
	if $Left.is_colliding() or $Right.is_colliding():
		if velocity.y >= 800:
			Damage(velocity.y / 20)
			if health <= 0:
				highDeath = true

func BottleAim():
	if fakeBottleCounter > 10:
		if aiming and Global.castMode == "hurl":
			var fakeBottle = loadFakeBottle.instance()
			add_child(fakeBottle)
			fakeBottleCounter = 0
	elif !aiming: 
		fakeBottleCounter += 1

func Climbing():
	if dontClimb <= 0:
		if $"Short ray".is_colliding() and !$"Upper ray".is_colliding():
			fly = false
			velocity = Vector2(0,0)
			if !is_on_wall():
				velocity.x = $Sprite.scale.x * 100
			if !climbingUp:
				climbing = true
				$Sprite.offset = Vector2(16, 5)
				$Sprite.play("Climbing")
			if Input.is_action_just_pressed("jump"):
				climbingUp = true
				$Sprite.play("ClimbingUp")
				yield($Sprite, "animation_finished")
				global_position += Vector2(20 * $Sprite.scale.x, -40)
				climbingUp = false
				climbing = false
			if climbingUp:
				$Sprite.offset = Vector2(16, -3)
			if Input.is_action_just_pressed("ui_down"):
				climbing = false
				velocity.x = -500 * $Sprite.scale.x
				dontClimb = 10
		else:
			climbing = false
			$Sprite.offset = Vector2(0, 0)
	if dontClimb > 0:
		dontClimb -= 1

func CollapseProcces():
	if IsOnEdge():
		if !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right"):
			$Sprite.play("Collapse")
			if $Left.is_colliding():
				$Sprite.scale.x = 1
			elif $Right.is_colliding():
				$Sprite.scale.x = -1

func IsOnEdge():
	if ($Left.is_colliding() and !$Right.is_colliding()) or (!$Left.is_colliding() and $Right.is_colliding()):
		return true
	else:
		return false
