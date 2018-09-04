extends Spatial

export var max_fireballs = 6
export var lifetime = 1.3
onready var fireball_prefab = $flame
onready var spawntime = OS.get_system_time_secs()

var fireballs = []
var accumulated_delta = 0

func _ready():
	randomize()

	fireballs.append({'sprite': fireball_prefab, 'forward': Vector3(randf(1),0,randf(1))})
	for f in range(max_fireballs):
		var fireball = fireball_prefab.duplicate()
		add_child(fireball)
		fireball.global_transform.origin = global_transform.origin
		fireballs.append({'sprite': fireball, 'forward': Vector3(rand_range(-1,1),0,rand_range(-1,1)).normalized()})
func _process(delta):
	accumulated_delta += delta
	for fireball in fireballs:
		fireball.sprite.scale -= Vector3(delta*10,delta*10,delta*10)
		fireball.sprite.global_transform.origin = fireball.sprite.global_transform.origin + fireball.forward * accumulated_delta * 2
	if OS.get_system_time_secs() >= spawntime + lifetime:
		queue_free()