extends StaticBody2D

var posGoalY = 0
var posY = 100
var posGoalX = 0
var posX = 100
var posStart

func _ready():
	rotation = deg2rad($"/root/Game/Cursor".wallRotation)
	posStart = $"/root/Game/Cursor/Wall".global_position
	position = posStart
	yield(get_tree().create_timer(9),"timeout")
	DestroyWall()
	if rotation > 0:
		posX *= -1

func _process(delta):
	if rotation == 0:
		if posY > posGoalY:
			posY -= 10
			position.y = posY + posStart.y
	elif rotation < 0:
		if posX > posGoalX:
			posX -= 10
			global_position.x = posX + posStart.x
	elif rotation > 0:
		if posX > posGoalX:
			posX -= 10
			global_position.x = -posX + posStart.x

func DestroyWall():
	$Collider/Wall.hide()
	$Collider.disabled = true
