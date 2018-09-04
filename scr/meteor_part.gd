extends RigidBody

var health
onready var explosion_prefab = preload('res://fx/fireball_fx.tscn')

func _ready():
	reset()

func damage(dmg):
	health -= dmg
	if health <= 0:
		var explosion = explosion_prefab.instance()
		explosion.global_transform.origin = global_transform.origin
		get_parent().add_child(explosion)
		queue_free()

func reset():
	randomize()
	health = randi() % 51