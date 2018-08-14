extends Node

# const
const V2_ZERO = Vector2(0,0)
const V3_ZERO = Vector3(0,0,0)
const V3_UP = Vector3(0,0,-1)
const V3_DOWN = Vector3(0,0,1)
const V3_LEFT = Vector3(-1,0,0)
const V3_RIGHT = Vector3(1,0,0)

# for this to work, this needs to be the only singleton in the game so the second tree child is always the current scene
onready var current_scene = get_parent().get_child(1)
onready var current_camera = current_scene.get_node('Camera2D')
var current_focus = null

var tileset_prototypes = {}
var current_tilemaps = {}
var current_projectiles = []

var fx_prototypes = {}

func _ready():
	if current_camera == null:
		current_camera = current_scene.get_node('Camera')
		current_camera.current = true
	print('** ',current_scene.name,' loaded **')
	print(current_camera)
	
	# load in fx prototypes
	fx_prototypes['dirt_hit'] = load('res://fx/FX_HitDirt.tscn')
	fx_prototypes['testbullet_hit'] = load('res://fx/bullet_hit.tscn')
	
	# set up initial state of all tiles
	tileset_prototypes['res://tiles/tiles01.tres'] = {
		'earthwall01': {
			'health': 25,
			'destroyed': 'earthback01'
			},
		'metalwall01': {
			'health': -1,
			'destroyed': 'metalwall01'
			},
		'metalwall02': {
			'health': -1,
			'destroyed': 'metalwall02'
			}
		}
	
	for n in current_scene.get_children():
		if n is TileMap:
			var tileset = n.tile_set
			var tileset_tiles = {}
			for id in tileset.get_tiles_ids():
				tileset_tiles[id] = tileset.tile_get_name(id)
			current_tilemaps[n.name] = { 'tilemap': n}
			var tiles = n.get_used_cells()
			current_tilemaps[n.name]['tiles'] = {}
			for tile in tiles:
				var tilename = tileset_tiles[n.get_cellv(tile)]
				var proto = tileset_prototypes[tileset.resource_path][tilename]
				current_tilemaps[n.name]['tiles'][tile] = {
					'name': tilename,
					'starting_health': proto['health'],
					'health': proto['health'],
					'damaged': tileset.find_tile_by_name(tilename + '_damage01'),
					'crumbling': tileset.find_tile_by_name(tilename + '_damage02'),
					'destroyed': tileset.find_tile_by_name(proto['destroyed'])
					}
	
func _process(delta):
	for p in current_projectiles:
		var colliding = false
		for tilemap in current_tilemaps:
			var collision_pos = current_tilemaps[tilemap].tilemap.world_to_map(p.position)
			var collision_id = current_tilemaps[tilemap].tilemap.get_cellv(collision_pos)
			if collision_id != -1:
				var current_tile = current_tilemaps[tilemap]['tiles'][collision_pos]
				if current_tile.health != 0:
					if current_tile.health > 0:
						current_tile.health = max(0, current_tile.health - 1) # change to dmg from projectile
					# swap sprites if sufficiently damaged
					if current_tile.health == current_tile.starting_health / 2:
						current_tilemaps[tilemap].tilemap.set_cellv(collision_pos, current_tile.damaged)
					if current_tile.health == current_tile.starting_health / 3:
						current_tilemaps[tilemap].tilemap.set_cellv(collision_pos, current_tile.crumbling)
					if current_tile.health == 0:
						current_tilemaps[tilemap].tilemap.set_cellv(collision_pos, current_tile.destroyed)
					
					var tile_hit = fx_prototypes['dirt_hit'].instance()
					current_scene.add_child(tile_hit)
					tile_hit.global_position = p.global_position

					var bullet_hit = fx_prototypes['testbullet_hit'].instance()
					current_scene.add_child(bullet_hit)
					bullet_hit.global_position = p.global_position
					
					p.queue_free()
					current_projectiles.erase(p)
	
	if current_focus != null:
		current_camera.position = current_focus.position

func set_focus(target):
	current_focus = target