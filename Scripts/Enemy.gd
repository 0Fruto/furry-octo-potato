extends KinematicBody2D

export var health = 100
export var light = false

func _ready():
	$AnimationPlayer.current_animation = "Levitation"

func _process(_delta):
	if health <= 0:
		Die()

func Damage(Damage):
	health -= Damage

func Die():
	$Enemy.hide()
	$Collider.disabled = true
