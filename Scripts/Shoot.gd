extends Node2D

var loadFireball

func _ready():
	loadFireball = preload("res://Prefabs/Fireball.tscn")

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		CastFireball()

func CastFireball():
	var fireball = loadFireball.instance()
	add_child(fireball)
