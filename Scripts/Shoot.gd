extends Node2D

var loadFireball
var loadCrystal

func _ready():
	loadFireball = preload("res://Prefabs/Fireball.tscn")
	loadCrystal = preload("res://Prefabs/Crystal.tscn")

func _process(_delta):
	if !$Player.casting && !$Player.tossingHat:
		if $Player.is_on_floor():
			if Input.is_action_just_pressed("attack"):
				CastFireball()
			
			if Input.is_action_just_pressed("wall"):
				CastCrystal()

func CastFireball():
	var fireball = loadFireball.instance()
	add_child(fireball)

func CastCrystal():
	var crystal = loadCrystal.instance()
	add_child(crystal)
