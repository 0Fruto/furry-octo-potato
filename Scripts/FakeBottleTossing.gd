extends KinematicBody2D

var slopeStop = 64
export var gravity = 1000.0
var velocity :Vector2
var startVelocity
var startPos
export var startRot = deg2rad(35)
export var speed = 100
var height = 300
var fly = true
var direction = 1

func _ready():
	direction = $"/root/Game/Player/Sprite".scale.x
	#scale.x = direction
	startPos = $"/root/Game/Player".global_position
	#speed = (end.distance_to(startGround) * gravity) / (height * sin(startRot * 2))
	startVelocity = Vector2(sin(startRot) * speed * direction, cos(startRot) * -speed)
	velocity = startVelocity
	for i in range(3):
		$LocalTrail.clear_points()
		yield(get_tree().create_timer(2),"timeout")
		speed += 100
		startVelocity = Vector2(sin(startRot) * speed * direction, cos(startRot) * -speed)
		startPos = $"/root/Game/Player".global_position
		global_position = startPos
		velocity = startVelocity
	get_parent().remove_child(self)

func _physics_process(delta):
	if $"/root/Game/Player".aiming == false:
		Delete()
	if $Ray.is_colliding():
		fly = false
	else:
		fly = true
	if fly:
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, Vector2(0, -1), slopeStop)

func Delete():
	$Sprite.hide()
	$Collider.disabled = true
	$Ray.enabled = false
	$LocalTrail.width = 0
