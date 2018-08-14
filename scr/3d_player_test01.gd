extends KinematicBody

export var movespeed = 20

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	var move = Main.V3_ZERO
	
	if Input.is_action_pressed('ui_up'):
		move += Main.V3_UP
	elif Input.is_action_pressed('ui_down'):
		move += Main.V3_DOWN
	if Input.is_action_pressed('ui_left'):
		move += Main.V3_LEFT
	elif Input.is_action_pressed('ui_right'):
		move += Main.V3_RIGHT
	
	move_and_slide(move * movespeed)
	
	Main.current_camera.translation = translation + Vector3(0,10,5)
	Main.current_camera.rotation_degrees = Vector3(-45,0,0)