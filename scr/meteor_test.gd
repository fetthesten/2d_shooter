extends Spatial

# prefabs
var meteor_part_prefab = preload("res://obj/meteor_part.tscn")

# exports
export var max_segments = 9
export var min_segments = 3
var regenerate = true

# members
var segments = []

func _ready():
	generate_meteor()

func _process(delta):
	if Input.is_key_pressed(KEY_Z) and regenerate:
		generate_meteor()
		regenerate = false
	if not Input.is_key_pressed(KEY_Z):
		regenerate = true

func generate_meteor():
	randomize()
	var num_segments = rand_range(min_segments,max_segments)
	
	for segment in segments:
		if weakref(segment).get_ref():
			segment.queue_free()
	segments.clear()
	
	for i in range(num_segments):
		var meteor_part = meteor_part_prefab.instance()
		add_child(meteor_part)
		if i == 0:	# first segment spawns at origin
			meteor_part.global_transform.origin = global_transform.origin
		else:
			var spawnpoints = []
			for j in range(4):	# cause there are four spawnpoints innit
				spawnpoints.append(segments[i-1].get_node('spawnpoint' + str(j + 1)))
			meteor_part.transform.origin = segments[i-1].transform.origin + spawnpoints[rand_range(0,len(spawnpoints))].transform.origin
		segments.append(meteor_part)
		#print('spawned a meteor part at ',segments[i].global_transform.origin)