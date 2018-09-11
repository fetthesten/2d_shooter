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
		'spray': 0.02,
		'spread': 0,
		'projectile_count': 1,
		'prefab': preload('res://obj/bullet_default.tscn')
		})
	weapons.append({
		'name': 'Spread Cannon',
		'cooldown': 30,
		'last_fired': 0,
		'damage': 2,
		'velocity': 90,
		'spray': 0,
		'spread': 0.1,
		'projectile_count': 5,
		'prefab': preload('res://obj/bullet_default.tscn')
		})
	current_weapon = 0

func fire(forward):
	var weapon = weapons[current_weapon]
	var current_time = OS.get_ticks_msec()
	if current_time > weapon.last_fired + weapon.cooldown:
		weapons[current_weapon].last_fired = current_time
		for p in weapon.projectile_count:
			var projectile = weapon.prefab.instance()
			projectile.set_damage(weapon.damage)
			Main.current_scene.add_child(projectile)
			projectile.global_transform.origin = global_transform.origin
			# randomize facing if weapon has imprecise aim
			if weapon.spray != 0:
				var spray = rand_range(-abs(weapon.spray), abs(weapon.spray)+abs(weapon.spray))
				forward = forward.rotated(Main.V3_GLOBALUP, spray)
			if weapon.spread != 0:
				var spread = range_lerp(p, 0, weapon.projectile_count, weapon.spread * -(weapon.projectile_count/2), weapon.spread * (weapon.projectile_count/2))
				forward = forward.rotated(Main.V3_GLOBALUP, spread)
				
			projectile.look_at(projectile.global_transform.origin + forward, Main.V3_GLOBALUP)
			projectile.set_axis_velocity(forward * weapon.velocity)

func get_weapon_name(weapon = current_weapon):
	return weapons[weapon].name

func switch_weapon(up = true):
	current_weapon+=1
	if current_weapon >= len(weapons):
		current_weapon=0