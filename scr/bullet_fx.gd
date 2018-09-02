extends RigidBody

onready var trail_renderer = $trail_renderer
var last_pos = Main.V3_ZERO

func _process(delta):
	var offset = (last_pos - global_transform.origin).normalized()
	last_pos = global_transform.origin
	trail_renderer.clear()
	trail_renderer.begin(Mesh.PRIMITIVE_TRIANGLES, null)
	trail_renderer.add_vertex(global_transform.origin + (global_transform.basis.x * -0.1))
	trail_renderer.add_vertex(global_transform.origin + (offset * 20))
	trail_renderer.add_vertex(global_transform.origin + (global_transform.basis.x * 0.1))
	trail_renderer.end()