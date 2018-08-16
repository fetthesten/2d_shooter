extends RigidBody2D

func _ready():
	get_parent().current_projectiles.append(self)