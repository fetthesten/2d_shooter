extends KinematicBody

onready var bullet_prefab = preload("res://obj/3d_bullet_test.tscn")

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

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _physics_process(delta):
	var coll = Main.current_world.intersect_ray(global_transform.origin, global_transform.origin + (-global_transform.basis.z.normalized() * cast_range), [self])
	var endpoint = global_transform.origin + (-global_transform.basis.z.normalized() * cast_range)
	
	if not coll.empty():
		Main.debug_label.text = coll.collider.name
		endpoint = coll.collider.global_transform.origin
		cast_target = coll.collider
		cast_hit = coll.position
	else:
		Main.debug_label.text = 'none'
		cast_hit = null
		cast_target = null

	Main.debug_draw.clear()
	Main.debug_draw.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	Main.debug_draw.add_vertex(global_transform.origin)
	Main.debug_draw.add_vertex(endpoint)
	Main.debug_draw.end()
	# draw line to meteor test
	Main.debug_draw.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	Main.debug_draw.add_vertex(global_transform.origin)
	Main.debug_draw.add_vertex($'../meteor_test'.global_transform.origin)
	Main.debug_draw.end()
	
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
	
	# shooting
	if Input.is_action_pressed('ui_accept'):
		var bullet = bullet_prefab.instance()
		get_parent().add_child(bullet)
		bullet.global_transform.origin = $shot_origin.global_transform.origin
		bullet.set_axis_velocity(forward * 60)
	
	# reposition camera
	Main.current_camera.translation = translation + Vector3(0,20,10)
	Main.current_camera.rotation_degrees = Vector3(-45,0,0)