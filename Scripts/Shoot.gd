extends Node2D

var loadFireball
var loadCrystal
var kickbackForce = 500

func _ready():
	loadFireball = preload("res://Prefabs/Fireball.tscn")
	loadCrystal = preload("res://Prefabs/Crystal.tscn")

func _process(_delta):
	if !$Player.casting && !$Player.tossingHat:
		if Input.is_action_just_pressed("attack"):
			CastFireball()
		if Input.is_action_just_pressed("wall"):
			CastCrystal()

func CastFireball():
	if $Player.mana > 10:
		var fireball = loadFireball.instance()
		add_child(fireball)
		$Player.mana -= 10
		if !$Player.is_on_floor():
			$Player.kickback(kickbackForce)

func CastCrystal():
	if $Player.mana > 10 && $Player.is_on_floor():
		var crystal = loadCrystal.instance()
		add_child(crystal)
		$Player.mana -= 10
