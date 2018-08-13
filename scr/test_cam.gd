extends Camera2D

export var zoom_sens = 0.05
const V2_ZERO = Vector2(0,0)
const V2_ZOOM_MIN = Vector2(0.01,0.01)
const V2_ZOOM_MAX = Vector2(3,3)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _input(event):
#	if event is InputEventMouseButton:
#		var zoom = self.zoom
#		var z = Vector2(zoom_sens, zoom_sens)
#		if event.button_index == BUTTON_WHEEL_UP:
#			if zoom < V2_ZOOM_MAX - z:
#				self.zoom = zoom + z
#		elif event.button_index == BUTTON_WHEEL_DOWN:
#			if zoom > V2_ZOOM_MIN + z:
#				self.zoom = zoom - z
#		else:
#			self.position = event.position
