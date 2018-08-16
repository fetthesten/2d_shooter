extends Node

# const
const V3_ZERO = Vector3(0,0,0)
const V3_GLOBALUP = Vector3(0,1,0)
const V3_UP = Vector3(0,0,-1)
const V3_DOWN = Vector3(0,0,1)
const V3_LEFT = Vector3(-1,0,0)
const V3_RIGHT = Vector3(1,0,0)

# helpers
var current_world = null
onready var debug_label = $debug_label
onready var debug_draw = $debug_draw
var mat = SpatialMaterial.new()

# for this to work, this needs to be the only singleton in the game so the second tree child is always the current scene
onready var current_scene = get_parent().get_child(1)
var current_camera
var current_focus = null

func _ready():
	if current_scene.get_node('Camera2D') != null:
		print('** found camera2d')
		current_camera = current_scene.get_node('Camera2D')
	elif current_scene.get_node('Camera') != null:
		print('** found camera')
		current_camera = current_scene.get_node('Camera')
	else:
		printerr('*! no camera found')
	
	current_camera.current = true
	
	mat.flags_unshaded = true
	mat.flags_use_point_size = true
	mat.albedo_color = Color(1,0,0,0.8)
	debug_draw.set_material_override(mat)
		
	print('** ',current_scene.name,' loaded **')
	print(current_camera)

func _physics_process(delta):
	if current_scene.get_class() == 'Spatial':
		current_world = current_scene.get_world().direct_space_state

func _process(delta):
	pass