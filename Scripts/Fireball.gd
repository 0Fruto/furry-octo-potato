extends KinematicBody2D

var spawnPos
export var xOffset = 20
export var yOffset = 7
export var speed = 10
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
var slowTimeMod

var angleMotion = false
var motion

func _ready():
	slowTimeMod = $"../Player".slowTimeMod
	$Texture.play("PreStart")
	lightRemCounter = $Light.energy
	$Light.energy = 0
	if $"../Player".aim:
		# = $"../Player/Sprite".scale.x
		rotation = $"../Player/Long ray".rotation
		xOffset = cos($"../Player/Long ray".rotation) * 2
		motion = Vector2(cos($"../Player/Long ray".rotation), sin($"../Player/Long ray".rotation))
		if $"../Player/Long ray".cast_to.x < 0:
			rotation = $"../Player/Long ray".rotation
			xOffset = -cos($"../Player/Long ray".rotation) * 2
			motion = Vector2(-cos($"../Player/Long ray".rotation), -sin($"../Player/Long ray".rotation))
			$"Texture".scale.x = -$"Texture".scale.x
		angleMotion = true
		yOffset = sin($"../Player/Long ray".rotation) * 2
		if $"../Player".scale.x < 0:
			motion = Vector2(cos($"../Player/Long ray".rotation) * -1, sin($"../Player/Long ray".rotation) * -1)
		motion = motion * Vector2(speed, speed)
		animCounter = 3
		$Texture.play("Idle")
		fly = true
		$Collider.disabled = false
		$Light.energy = 0.4
	else:
		$"Texture".scale.x = $"../Player/Sprite".scale.x
	if $"../Player/Short ray".is_colliding():
		colPoint = $"../Player/Short ray".get_collision_point()
		speed = 10
		speedMode = true
		xOffset = 0
	$Texture.playing = true
	spawnPos = $"../Player".global_position + Vector2(xOffset * $"../Player/Sprite".scale.x, yOffset)
	global_position = spawnPos
	

func _process(delta):
	if !removeLight:
		if !angleMotion:
			lightAddCounter += delta * 2
			$Light.energy += delta * 2
		else:
			lightAddCounter += delta * 20
			$Light.energy += delta * 20
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
		var tempSpeed = speed
		if $"../Player".aim:
			tempSpeed = speed * slowTimeMod
		var body
		if angleMotion:
			if !$"../Player".aim:
				body = move_and_collide(motion)
			if $"../Player".aim:
				body = move_and_collide(motion * slowTimeMod)
		else:
			body = move_and_collide(Vector2(tempSpeed * $"Texture".scale.x, 0))
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
