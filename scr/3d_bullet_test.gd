extends RigidBody

func collide(collider):
	queue_free()
	collider.queue_free()
