extends Node2D


var loadFireball

func _ready():
	loadFireball = preload("res://Prefabs/EnemyFireball.tscn")

func CastFireball():
	var fireball = loadFireball.instance()
	add_child(fireball)
