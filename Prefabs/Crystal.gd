extends KinematicBody2D

var spawnPos
export var xOffset = 20
export var speed = 5
var move = false
var animCounter = 1
var remove = false
var removeLight = false
var lightRemCounter
var enemy

func _ready():
	lightRemCounter = $Light.energy
	$Animator.play("Pre")
	$Animator.playing = true
	spawnPos = $"../Player".global_position + Vector2(xOffset * $"../Player/Sprite".scale.x, 16)
	$Animator.scale.x = $"../Player/Sprite".scale.x
	global_position = spawnPos

func _process(_delta):
	if move:
		var body = move_and_collide(Vector2(speed * $Animator.scale.x, 0))
		if body:
			if body != $"/root/Game/Player":
				#if body.collider.name == "TileMap":
					#$Texture.offset.x = -4
					#$Texture.play("Wall")
				if body.collider.name == "Enemy":
					$Animator.offset.y = -13
					$Animator.offset.x = 27
					$Light.offset.x = 27 * $Animator.scale.x
					$Animator.play("Idle")
					enemy = body
				
				$Collider.disabled = true
				move = false
				remove = true


func _on_Animator_animation_finished():
	if animCounter == 1:
		animCounter += 1
		$Animator.play("Move")
		move = true
