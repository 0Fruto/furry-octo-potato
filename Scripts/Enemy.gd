extends KinematicBody2D

export var health = 100
export var light = false
var velocity = Vector2()
var gravity = 1000
var speed = 30
var freeze = false
var walkRadius = 100
var walkPoint1 = 0
var walkPoint2 = 0
var direction = 1
onready var player = $"/root/Game/Player"
var CD = 5
var shoot = true

var seeEnemy = false

var mayRotate = true

func _ready():
	$Cast.cast_to = Vector2(0,0)
	walkPoint1 = global_position.x + walkRadius
	walkPoint2 = global_position.x - walkRadius

func _process(delta):
	EnemyDetection()
	AnimationProcess()
	if mayRotate and !seeEnemy and $WallCast.is_colliding():
		mayRotate = false
		direction *= -1
		yield(get_tree().create_timer(1),"timeout")
		mayRotate = true
	if !seeEnemy and global_position.x > walkPoint1:
		direction = -1
	elif !seeEnemy and global_position.x < walkPoint2:
		direction = 1
	elif !seeEnemy and global_position.x < walkPoint1 and global_position.x > walkPoint2:
		if direction == 0:
			direction = 1
	elif seeEnemy:
		direction = 0
		if shoot:
			$"..".CastFireball()
			shoot = false
			$CD.start(CD)
			yield($CD, "timeout")
			shoot = true
	
	Go(direction)
	velocity.y += gravity * delta
	move_and_slide(velocity, Vector2(0, -1))
	if health <= 0:
		Die()
	$Label.text = str(seeEnemy)

func AnimationProcess():
	if velocity.x == 0:
		$Sprite.play("Idle")
	else:
		$Sprite.play("Run")
	if velocity.x > 0:
		$Sprite.flip_h = false
		$WallCast.cast_to.x = 30
		#$Cast.cast_to.x = 200
		$Area/Collider.scale.x = 1
	if velocity.x < 0:
		$Sprite.flip_h = true
		$WallCast.cast_to.x = -30
		#$Cast.cast_to.x = -200
		$Area/Collider.scale.x = -1

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

func Go(dir):
	velocity.x = speed * dir

func EnemyDetection():
	if $Area.overlaps_body(player):
		$Cast.cast_to = player.global_position - global_position
		if $Cast.is_colliding():
			if $Cast.get_collider().name == "Player":
				seeEnemy = true
			$Timer.start(5)
			yield($Timer, "timeout")
			if !$Cast.is_colliding():
				seeEnemy = false
			elif $Cast.get_collider().name != "Player":
				seeEnemy = false
	
