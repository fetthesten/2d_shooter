extends RigidBody2D

func _ready():
	Main.current_projectiles.append(self)