extends Panel

func Pause():
	show()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func Resume():
	hide()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func Restart():
	get_tree().paused = false
	get_tree().reload_current_scene()
	$"../..".alive = true

func _on_Resume_pressed():
	Resume()


func _on_Quit_pressed():
	get_tree().quit()


func _on_Restart_pressed():
	Restart()
