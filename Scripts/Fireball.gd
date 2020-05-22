extends KinematicBody2D

var spawnPos
export var offset = 20
export var speed = 5
var fly = false
var animCounter = 1

func _ready():
	$Texture.play("PreStart")
	$Texture.playing = true
	spawnPos = $"../Player".global_position + Vector2(offset * $"../Player/Sprite".scale.x, 3)
	$"Texture".scale.x = $"../Player/Sprite".scale.x
	global_position = spawnPos
	$Collider.disabled = false

func _process(_delta):
	if fly:
		var body = move_and_collide(Vector2(speed * $"Texture".scale.x, 0))
		if body:
			if body != $"/root/Game/Player":
				$Texture.hide()
				if body.collider.name == "Enemy":
					body.collider.Damage(100)
				$Collider.disabled = true


func _on_Texture_animation_finished():
	if animCounter == 1:
		$Texture.play("Start")
	if animCounter == 2:
		$Texture.play("Idle")
		fly = true
	
	if animCounter < 3:
		animCounter += 1
