extends RigidBody

var damage

func set_damage(dmg):
	damage = dmg
	
func impact(body):
	body.damage(damage)
	queue_free()