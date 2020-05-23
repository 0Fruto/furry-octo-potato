extends KinematicBody2D

var spawnPos
export var offset = 20
export var speed = 5
var fly = false
var animCounter = 1
var remove = false
var removeLight = false
var lightRemCounter
var lightAddCounter = 0
var enemy
var speedMode = false
var colPoint
var damage = 100
export var disappearCounterGoal = 2
var disappearCounter = 0
var disappear = true

func _ready():
	if $"../Player/Short ray".is_colliding():
		colPoint = $"../Player/Short ray".get_collision_point()
		speed = 10
		speedMode = true
		offset = 0
	lightRemCounter = $Light.energy
	$Light.energy = 0
	$Texture.play("PreStart")
	$Texture.playing = true
	spawnPos = $"../Player".global_position + Vector2(offset * $"../Player/Sprite".scale.x, 7)
	$"Texture".scale.x = $"../Player/Sprite".scale.x
	global_position = spawnPos
	

func _process(delta):
	if !removeLight:
		lightAddCounter += delta * 2
		$Light.energy += delta * 2
	if disappear:
		disappearCounter += delta
		if disappearCounter >= disappearCounterGoal:
			removeLight = true
			$Texture.play("Disappear")
			disappear = false
			$Collider.disabled = true
			remove = true
			fly = false
	if remove:
		fly = false
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
				disappear = false
				if speedMode:
					$Texture.offset.x = -10
				if body.collider.name == "TileMap":
					if !speedMode:
						$Texture.offset.x = -4
					else:
						global_position.x = colPoint.x
						$Texture.offset.x = -16
					$Texture.play("Wall")
				if body.collider.name == "Enemy":
					global_position.x = body.collider.global_position.x
					if !speedMode:
						$Texture.offset.x = -7
					$Texture.play("Enemy")
					enemy = body
				
				removeLight = true
				$Collider.disabled = true
				fly = false
				remove = true

func _on_Texture_animation_finished():
	if remove:
		if enemy:
			enemy.collider.Damage(damage)
		$Texture.hide()
	if animCounter == 1:
		if !speedMode:
			$Texture.play("Start")
		else:
			$Texture.play("Idle")
			fly = true
		$Collider.disabled = false
	if animCounter == 2:
		$Texture.play("Idle")
		fly = true
	
	if animCounter < 3:
		animCounter += 1
