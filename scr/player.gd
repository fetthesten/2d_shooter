extends KinematicBody2D

var cam
var last_x_dir = 1
var last_y_dir = 1
var deadzone_move = 0.2
var deadzone_fire = 0.2
onready var res_bullet = load('res://obj/testbullet.tscn')

const V2_ZERO = Vector2(0,0)
const V2_UP = Vector2(0,-1)
const V2_RIGHT = Vector2(1,0)

func _ready():
	# maybe make this a global in singleton...
	cam = $'../Camera2D'

func _process(delta):
	var move = V2_ZERO
	var gravity = Vector2(0,300)
	var fire = V2_ZERO
	
	# pad movement
	var xAxis = Input.get_joy_axis(0, JOY_AXIS_0)
	var yAxis = Input.get_joy_axis(0, JOY_AXIS_1)
	if abs(xAxis) > deadzone_move:
		move.x = xAxis
	if abs(yAxis) > deadzone_move:
		move.y = yAxis
	
	# pad firing
	xAxis = Input.get_joy_axis(0, JOY_AXIS_2)
	yAxis = Input.get_joy_axis(0, JOY_AXIS_3)
	if abs(xAxis) > deadzone_fire:
		fire.x = xAxis
	if abs(yAxis) > deadzone_fire:
		fire.y = yAxis
	
	# keyboard movement
	if Input.is_action_pressed("ui_left"):
		move.x = -1
	elif Input.is_action_pressed("ui_right"):
		move.x = 1
	if Input.is_action_pressed("ui_up"):
		move.y = -1
	elif Input.is_action_pressed("ui_down"):
		move.y = 1
	
	if move.x != 0:
		last_x_dir = move.x
	if move.y != 0:
		last_y_dir = move.y
	
	move *= 400
	
	move_and_slide(move, V2_UP)
	if not is_on_floor() and move.y == 0:
		move_and_slide(gravity)
	
	cam.position = position - Vector2(200,100)
	
	if fire != V2_ZERO:
		$shotOrigin.look_at(global_position + fire)
	else:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			$shotOrigin.look_at(get_global_mouse_position())
			fire.x = 1
		
	if fire != V2_ZERO:
		var bullet_angle = V2_RIGHT.rotated($shotOrigin.rotation)
		
		var bullet = res_bullet.instance()
		get_parent().add_child(bullet)
		bullet.position = $shotOrigin.global_position
		bullet.set_axis_velocity(bullet_angle * 400)
		