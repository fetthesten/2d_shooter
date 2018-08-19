extends Spatial

# prefabs
var meteor_part_prefab = preload("res://obj/meteor_part.tscn")

# exports
export var max_segments = 9
export var min_segments = 3

# members
var segments = []

func _ready():
	var num_segments = rand_range(min_segments,max_segments)
	
	for i in range(num_segments):
		var meteor_part = meteor_part_prefab.instance()
		get_parent().add_child(meteor_part)
		if i == 0:	# first segment spawns at origin
			meteor_part.global_transform.origin = global_transform.origin
		else:
			var spawnpoints = []
			for j in range(4):	# cause there are four spawnpoints innit
				spawnpoints.append(segments[i-1].get_node('spawnpoint' + str(j + 1)))
			meteor_part.global_transform.origin = spawnpoints[floor(rand_range(0,len(spawnpoints)))].global_transform.origin
		segments.append(meteor_part)
		print('spawned a meteor part at ',segments[i].global_transform.origin)