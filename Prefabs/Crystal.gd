extends KinematicBody2D

var spawnPos
export var xOffset = 20
export var speed = 5
var move = false
var animCounter = 1
var remove = false
var removeLight = false
var lightRemCounter
var lightAddCounter = 0
var enemy
var speedMode = false
export var removeTimerGoal = 0.5
var removeTimer = 0
var crystal = false
var colPoint
export var removeCrystalTimerGoal = 10
var removeCrystalTimer = 0

func _ready():
	if $"../Player/Short ray".is_colliding():
		colPoint = $"../Player/Short ray".get_collision_point()
		speed = 10
		speedMode = true
		xOffset = 0
	lightRemCounter = $Light.energy
	$Light.energy = 0
	$Animator.play("Pre")
	$Animator.playing = true
	spawnPos = $"../Player".global_position + Vector2(xOffset * $"../Player/Sprite".scale.x, 16)
	$Animator.scale.x = $"../Player/Sprite".scale.x
	global_position = spawnPos

func _process(delta):
	if !removeLight:
		if lightAddCounter < lightRemCounter:
			lightAddCounter += delta * 4
			$Light.energy += delta * 4
	if crystal and removeCrystalTimer < removeCrystalTimerGoal:
		removeCrystalTimer += delta
	if removeCrystalTimer > removeCrystalTimerGoal:
		$Animator.play("Break")
		removeLight = true
		remove = true
	if remove:
		if removeTimer < removeTimerGoal * 4:
			removeTimer += removeTimerGoal
	if removeLight:
		if lightRemCounter > 0:
			lightRemCounter -= delta * 4
			$Light.energy -= delta * 4
		else:
			$Light.enabled = false
	if !remove && !crystal:
		removeTimer += delta
	if removeTimer >= removeTimerGoal && !crystal:
		$Animator.z_index = -2
		$Collider.disabled = true
		$Animator.offset.y += 1
	if removeTimer >= removeTimerGoal * 2 && !crystal:
		remove = true
		move = false
		removeLight = true
	if move:
		var body = move_and_collide(Vector2(speed * $Animator.scale.x, 0))
		if body:
			if body != $"/root/Game/Player":
				if body.collider.name == "TileMap":
					if !speedMode:
						$Animator.offset.x = -1
					else:
						global_position.x = colPoint.x
						$Animator.offset.x = -10
				if body.collider.name == "Enemy":
					crystal = true
					body.collider.Freeze()
					if !speedMode:
						$Animator.offset.x = 27
					else:
						global_position.x = body.collider.global_position.x
					$Animator.offset.y = -13
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
