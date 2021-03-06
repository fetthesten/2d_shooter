extends KinematicBody

onready var bullet_prefab = preload("res://obj/3d_bullet_test.tscn")

export var deadzone_fire = 0.2
export var movespeed = 60
export var max_movespeed = 40
export var deceleration = 60
var current_movespeed = 0
var last_move_time = 0
var last_move_dir = Main.V3_ZERO
var forward

var cast_hit = null
var cast_target = null
var cast_range = 50

var mouse_pos = Main.V3_ZERO
var mouse_update_player_pos = Main.V3_ZERO	# to calculate firing vector offset if player moves after aiming

var test_weaponswitch = true

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _physics_process(delta):
	var coll = Main.current_world.intersect_ray(global_transform.origin, global_transform.origin + (-global_transform.basis.z.normalized() * cast_range), [self])
	var endpoint = global_transform.origin + (-global_transform.basis.z.normalized() * cast_range)
	
	# store info about what the player is pointing towards, just because
	if not coll.empty():
		Main.debug_label.text = coll.collider.name
		endpoint = coll.collider.global_transform.origin
		cast_target = coll.collider
		cast_hit = coll.position
	else:
		Main.debug_label.text = 'none'
		cast_hit = null
		cast_target = null

	# debug aiming line 
	Main.debug_draw.clear()
	Main.debug_draw.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	Main.debug_draw.add_vertex(global_transform.origin)
	Main.debug_draw.add_vertex(endpoint)
	Main.debug_draw.end()
	
func _process(delta):
	var move = Main.V3_ZERO
	var fire = Main.V3_ZERO
	
	# get move input
	# axis strength doesn't matter, smooth velocity based on how long input has been received
	if Input.is_action_pressed('ui_up') or Input.is_action_pressed('pad_leftstick_up'):
		move += Main.V3_UP
	elif Input.is_action_pressed('ui_down') or Input.is_action_pressed('pad_leftstick_down'):
		move += Main.V3_DOWN
	if Input.is_action_pressed('ui_left') or Input.is_action_pressed('pad_leftstick_left'):
		move += Main.V3_LEFT
	elif Input.is_action_pressed('ui_right') or Input.is_action_pressed('pad_leftstick_right'):
		move += Main.V3_RIGHT
	
	# get fire input
	# pad firing
	var xAxis = Input.get_joy_axis(0, JOY_AXIS_2)
	var yAxis = Input.get_joy_axis(0, JOY_AXIS_3)
	if abs(xAxis) > deadzone_fire:
		fire.x = xAxis
	if abs(yAxis) > deadzone_fire:
		fire.z = yAxis
		
	if move != Main.V3_ZERO:
		# increase velocity if moving
		current_movespeed += movespeed * delta
		current_movespeed = min(current_movespeed,max_movespeed)
	else:
		# decelerate
		current_movespeed -= deceleration * delta
		current_movespeed = max(current_movespeed, 0)
	
	# used to check if rotation interpolation should be performed
	if move != last_move_dir:
		last_move_time = OS.get_ticks_msec()
	last_move_dir = move
	
	transform = transform.orthonormalized()
	
	# rotation
	# snap to final orientation, then slerp towards it 
	# if last directional change occurred recently
	var current_rot = Quat(transform.basis)
	if move != Main.V3_ZERO:
		look_at(global_transform.origin + move.normalized(), Main.V3_GLOBALUP)
	var target_rot = Quat(transform.basis)
	var step = float((OS.get_ticks_msec() - last_move_time)) / 500

	if step <= 1:
		transform.basis = Basis(current_rot.slerp(target_rot, step))
	
	forward = -global_transform.basis.z
	
	move_and_slide(forward * current_movespeed)
	
	Main.debug_label.text += '\npos: ' + str(global_transform.origin)
	Main.debug_label.text += '\nweapon: ' + $weapons.get_weapon_name()
	
	# aim offset for when player is moving while firing using mouse
	var aim_offset = Main.V3_ZERO
	if mouse_update_player_pos != global_transform.origin:
		aim_offset = mouse_update_player_pos - global_transform.origin
	Main.draw_mouse_cursor(mouse_pos - aim_offset)
	
	# test weapon switch
	if Input.is_key_pressed(KEY_X) and test_weaponswitch:
		$weapons.switch_weapon()
		test_weaponswitch = false
	if not Input.is_key_pressed(KEY_X):
		test_weaponswitch = true
	
	# shooting
	# pad right stick takes priority
	if fire != Main.V3_ZERO:
		$weapons.fire(fire.normalized())
	elif Input.is_mouse_button_pressed(BUTTON_LEFT):
		$weapons.fire((mouse_pos - (global_transform.origin + aim_offset)).normalized())
	
	# reposition camera
	Main.current_camera.translation = translation + Vector3(0,30,20)
	Main.current_camera.rotation_degrees = Vector3(-45,0,0)

func mouse_click(camera, event, click_position, click_normal, shape_idx):
	mouse_pos = Vector3(click_position.x,0,click_position.z)
	mouse_update_player_pos = Vector3(global_transform.origin)
