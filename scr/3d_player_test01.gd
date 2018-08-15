extends KinematicBody

onready var bullet_prefab = preload("res://obj/3d_bullet_test.tscn")

export var movespeed = 20
var last_move_time = 0
var last_move_dir = Main.V3_ZERO

var cast_hit = null
var cast_target = null
var cast_range = 50

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _physics_process(delta):
	var coll = Main.current_world.intersect_ray(global_transform.origin, global_transform.origin + (-global_transform.basis.z * cast_range), [self])
	var endpoint = global_transform.origin + (-global_transform.basis.z * cast_range)
	
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

func _process(delta):
	var move = Main.V3_ZERO
	var forward = -global_transform.basis.z
	
	if Input.is_action_pressed('ui_up'):
		move += Main.V3_UP
	elif Input.is_action_pressed('ui_down'):
		move += Main.V3_DOWN
	if Input.is_action_pressed('ui_left'):
		move += Main.V3_LEFT
	elif Input.is_action_pressed('ui_right'):
		move += Main.V3_RIGHT
	
	if Input.is_action_pressed('ui_accept'):
		var bullet = bullet_prefab.instance()
		get_parent().add_child(bullet)
		bullet.global_transform.origin = $shot_origin.global_transform.origin
		bullet.set_axis_velocity(forward * 20)
	
	if move != last_move_dir:
		last_move_time = OS.get_ticks_msec()
	last_move_dir = move
	
	move_and_slide(move * movespeed)
	
	if move != Main.V3_ZERO:
		Main.rotation_helper.look_at(Main.rotation_helper.translation + move, Main.V3_GLOBALUP)
	var step = float((OS.get_ticks_msec() - last_move_time)) / 500
	
	if step <= 1:
		rotation_degrees = rotation_degrees.linear_interpolate(Main.rotation_helper.rotation_degrees, step)
	
	Main.current_camera.translation = translation + Vector3(0,10,5)
	Main.current_camera.rotation_degrees = Vector3(-45,0,0)
	