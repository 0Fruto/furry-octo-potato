extends Node2D

var loadFireball
var loadCrystal
var loadWall
var kickbackForce = 500

func _ready():
	loadFireball = preload("res://Prefabs/Fireball.tscn")
	loadCrystal = preload("res://Prefabs/Crystal.tscn")
	loadWall = preload("res://Prefabs/Wall.tscn")

func _process(_delta):
	if !$Player.casting && !$Player.tossingHat && !$Player.climbing:
		if Input.is_action_pressed("wall"):
			$Player.aiming = true
			Global.castMode = "wall"
		elif Input.is_action_just_released("wall"):
			if $Cursor/Cast.is_colliding() or $Cursor/CastL.is_colliding() or $Cursor/CastR.is_colliding():
				BuildWall()
		
		if Input.is_action_pressed("attack"):
			$Player.aiming = true
			Global.castMode = "hurl"
		elif Input.is_action_just_released("attack"):
			pass
		if !Input.is_action_pressed("wall") and !Input.is_action_pressed("attack"):
			$Player.aiming = false

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

func BuildWall():
	var wall = loadWall.instance()
	add_child(wall)
