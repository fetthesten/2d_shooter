extends Node2D


func _ready():
	$AnimationPlayer.play("walking")

func _process(delta):
	#$chest/upperarm_r.rotation = (parent.position.x - initial_x_offset) / 100
	#$chest/upperarm_r/underarm_r.rotation = (parent.position.x - initial_x_offset) / 100
	pass