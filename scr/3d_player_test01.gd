extends KinematicBody

onready var bullet_prefab = preload("res://obj/3d_bullet_test.tscn")

export var movespeed = 20
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
	forward = -global_transform.basis.z
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

	var move = Main.V3_ZERO
	
	if Input.is_action_pressed('ui_up'):
		move += Main.V3_UP
	elif Input.is_action_pressed('ui_down'):
		move += Main.V3_DOWN
	if Input.is_action_pressed('ui_left'):
		move += Main.V3_LEFT
	elif Input.is_action_pressed('ui_right'):
		move += Main.V3_RIGHT
	
	if move != last_move_dir:
		last_move_time = OS.get_ticks_msec()
	last_move_dir = move
	
	$move_helper.global_transform.origin = global_transform.origin + move
	
	# rotation
	var current_rot = Vector3(rotation)
	look_at(global_transform.origin + move.normalized(), Main.V3_GLOBALUP)
	var target_rot = Vector3(rotation)
	var step = float((OS.get_ticks_msec() - last_move_time)) / 500

	Main.debug_label.text += '\ncurrent_rot: ' + str(current_rot) + '\ntarget_rot: ' + str(target_rot)

	if step <= 1:
		rotation = current_rot.linear_interpolate(target_rot, step)

	var move_index = forward.ceil()
	Main.debug_label.text += '\nmove_index: ' + str(move_index)
	
	move_and_slide(forward * movespeed)
	
	Main.current_camera.translation = translation + Vector3(0,10,5)
	Main.current_camera.rotation_degrees = Vector3(-45,0,0)
	
func _process(delta):
	if Input.is_action_pressed('ui_accept'):
		var bullet = bullet_prefab.instance()
		get_parent().add_child(bullet)
		bullet.global_transform.origin = $shot_origin.global_transform.origin
		bullet.set_axis_velocity(forward * 20)
	