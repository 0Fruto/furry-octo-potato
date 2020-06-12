extends KinematicBody2D

var spawnPos
export var xOffset = 20
export var yOffset = 0
export var speed = 10
var fly = true
var animCounter = 1
var remove = false
var enemy
var colPoint
var damage = 100
export var disappearCounterGoal = 2
var disappearCounter = 0
var disappear = true

var motion

func _ready():
	$Texture.play("Idle")
	GetStartRot()
	$Texture.playing = true
	spawnPos = $"../Enemy".global_position + Vector2(xOffset, yOffset + 5)
	global_position = spawnPos

func _process(_delta):
	if fly:
		var body = move_and_collide(motion)
		if body:
			if body.collider.name == "TileMap":
				$Texture.offset.x = -16
				$Texture.play("Wall")
			if body.collider.name == "Wall":
				$Texture.offset.x = -16
				$Texture.play("Wall")
			if body.collider.name == "Player":
				global_position.x = body.collider.global_position.x
				$Texture.play("Enemy")
				body.collider.Damage(damage)
			Delete()
		#	remove = true

func GetStartRot():
	var difference = $"/root/Game/Player".global_position - $"../Enemy".global_position
	rotation = atan2(difference.y, difference.x)
	xOffset = cos(rotation) * 25
	yOffset = sin(rotation) * 25
	motion = Vector2(cos(rotation), sin(rotation))
	motion = motion * Vector2(speed, speed)

func Delete():
	disappear = true
	$Collider.disabled = true
	fly = false
	$Texture.play("Disappear")
	yield($Texture,"animation_finished")
	$Texture.hide()
	$Light.energy = 0
