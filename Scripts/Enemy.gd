extends KinematicBody2D

export var health = 100
export var light = false
var velocity = Vector2()
var gravity = 1000
var speed = 10
var freeze = false

func _ready():
	pass

func _process(delta):
	if !freeze:
		AnimationProcess()
		#Go(-1)
		velocity.y += gravity * delta
		var moveAndSlide = move_and_slide(velocity, Vector2(0, -1))
	if health <= 0:
		Die()

func AnimationProcess():
	if velocity.x != 0:
		$Sprite.play("Run")
	else:
		$Sprite.play("Idle")
	if velocity.x > 0:
		$Sprite.flip_h = false
	if velocity.x < 0:
		$Sprite.flip_h = true

func Damage(Damage):
	health -= Damage

func Freeze(time):
	$Sprite.playing = false
	freeze = true
	yield(get_tree().create_timer(time), "timeout")
	$Sprite.playing = true
	freeze = false

func Die():
	yield(get_tree().create_timer(0.3), "timeout")
	$Sprite.hide()
	$Collider.disabled = true

func Go(direction):
	velocity.x = speed * direction
