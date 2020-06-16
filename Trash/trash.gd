extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if !$putin1.playing:
		$putin1.playing = true
	if !$putin2.playing:
		$putin2.playing = true
	if !$putin3.playing:
		$putin3.playing = true
	
	if !$Label/AnimationPlayer.is_playing():
		$Label/AnimationPlayer.play("Trash")
