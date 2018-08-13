extends KinematicBody2D

func _ready():
	Main.set_focus(self)

func _process(delta):
	var move = Main.V2_ZERO
	if Input.is_action_pressed('ui_left'):
		move.x = -1
	elif Input.is_action_pressed('ui_right'):
		move.x = 1
	if Input.is_action_pressed('ui_up'):
		move.y = -1
	elif Input.is_action_pressed('ui_down'):
		move.y = 1
		
	move_and_slide(move * 200)
	
	
