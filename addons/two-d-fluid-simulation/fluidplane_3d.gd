extends Node3D

func _ready():
	$FluidViewports.update_size(Vector2(300, 200))
	var vp = $FluidViewports.get_node("DyeViewport")
	$FluidPlaneMesh.get_surface_override_material(0).emission_texture = vp.get_texture()

	# do the startup splats
	await get_tree().create_timer(0.1).timeout
	for i in range(10):
		$FluidViewports.start_dye(Color.from_hsv(randf(), 0.5, 1.0)*3)
		$FluidViewports.splat(Vector2(randf(), randf()), Vector2(randf_range(-19,19),randf_range(-19,19)))
		await get_tree().process_frame
	$FluidViewports.stop_dye()

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			$FluidViewports.start_dye(Color.from_hsv(randf(), 0.5, 1.0))
		else:
			$FluidViewports.stop_dye()

	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var screen_size = Vector2(DisplayServer.window_get_size_with_decorations(event.window_id))
		$FluidViewports.splat(event.position/screen_size, event.velocity/screen_size)
		print(event.position/screen_size)
