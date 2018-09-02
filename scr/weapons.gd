extends Spatial

var weapons = []
var current_weapon

func _ready():
	# load weapons
	# load these from file eventually
	weapons.append({
		'name': 'Vulcan Cannon',
		'cooldown': 30,
		'last_fired': 0,
		'damage': 2,
		'velocity': 90,
		'spread': 0.02,
		'prefab': preload('res://obj/bullet_default.tscn')
		})
	current_weapon = 0

func fire(forward):
	var weapon = weapons[current_weapon]
	var current_time = OS.get_ticks_msec()
	if current_time > weapon.last_fired + weapon.cooldown:
		weapons[current_weapon].last_fired = current_time
		var projectile = weapon.prefab.instance()
		Main.current_scene.add_child(projectile)
		projectile.global_transform.origin = global_transform.origin
		if weapon.spread != 0:
			var spread = rand_range(-weapon.spread, weapon.spread+weapon.spread)
			forward = forward.rotated(Main.V3_GLOBALUP, spread)
		projectile.look_at(projectile.global_transform.origin + forward, Main.V3_GLOBALUP)
		projectile.set_axis_velocity(forward * weapon.velocity)

func get_weapon_name(weapon = current_weapon):
	return weapons[weapon].name