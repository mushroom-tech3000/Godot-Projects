extends Node



	
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed: 
			var pos: Variant = clicked()
			if pos == null: return
			if event.button_index == MOUSE_BUTTON_LEFT:	get_parent().clicked(pos)

func clicked():
	var cam = get_viewport().get_camera_3d()
	var space_state = get_parent().get_world_3d().direct_space_state
	var mpos_2d = get_viewport().get_mouse_position()
	var raycast_origin = cam.project_ray_origin(mpos_2d)
	var raycast_end = cam.project_position(mpos_2d, 500)
	var query = PhysicsRayQueryParameters3D.create(raycast_origin, raycast_end)
	var intersect = space_state.intersect_ray(query)
	if intersect.has("position"): return intersect.position.round()
	return null
