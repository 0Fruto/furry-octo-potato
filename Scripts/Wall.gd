extends StaticBody2D

var posGoalY = 0
var posY = 100
var posStart

func _ready():
	posStart = $"/root/Game/Cursor/Cast".get_collision_point()
	position = posStart
	yield(get_tree().create_timer(9),"timeout")
	DestroyWall()

func _process(delta):
	if posY > posGoalY:
		posY -= 1
		position.y = posY + posStart.y

func DestroyWall():
	$Collider/Wall.hide()
	$Collider.disabled = true
