extends KinematicBody2D

var spawnPos
export var offset = 20
export var speed = 5
var fly = false
var animCounter = 1
var remove = false
var removeLight = false
var lightRemCounter
var enemy

func _ready():
	lightRemCounter = $Light.energy
	$Texture.play("PreStart")
	$Texture.playing = true
	spawnPos = $"../Player".global_position + Vector2(offset * $"../Player/Sprite".scale.x, 3)
	$"Texture".scale.x = $"../Player/Sprite".scale.x
	global_position = spawnPos
	

func _process(delta):
	if removeLight:
		if lightRemCounter > 0:
			lightRemCounter -= delta
			$Light.energy -= delta
		else:
			$Light.enabled = false
	if fly:
		var body = move_and_collide(Vector2(speed * $"Texture".scale.x, 0))
		if body:
			if body != $"/root/Game/Player":
				if body.collider.name == "TileMap":
					$Texture.offset.x = -4
					$Texture.play("Wall")
				if body.collider.name == "Enemy":
					$Texture.offset.x = 7
					$Texture.play("Enemy")
					enemy = body
				
				removeLight = true
				$Collider.disabled = true
				fly = false
				remove = true

func _on_Texture_animation_finished():
	if remove:
		if enemy:
			enemy.collider.Damage(100)
		$Texture.hide()
	if animCounter == 1:
		$Texture.play("Start")
		$Collider.disabled = false
	if animCounter == 2:
		$Texture.play("Idle")
		fly = true
	
	if animCounter < 3:
		animCounter += 1
