extends Control

func _ready():
	_on_option_button_item_selected(0)
	$FluidViewports.update_size(size)

	# do the startup splats
	await get_tree().create_timer(0.1).timeout
	for i in range(10):
		$FluidViewports.start_dye(Color.from_hsv(randf(), 0.5, 1.0)*3)
		$FluidViewports.splat(Vector2(randf(), randf()), Vector2(randf_range(-19,19),randf_range(-19,19)))
		await get_tree().process_frame
	$FluidViewports.stop_dye()

func _on_option_button_item_selected(index):
	var selviewport = $OptionButton.get_item_text(index)
	if selviewport.begins_with("PressureViewport"):
#		$TextureRect.texture = lastpressureviewport.get_texture()
		var vp = $FluidViewports/PressureNode.get_node(selviewport)
		var vpt = vp.get_node("Sprite2D").get_texture()
		$TextureRect.texture = vp.get_texture()
	else:
		var vp = $FluidViewports.get_node(selviewport)
		print(vp.use_hdr_2d)
		$TextureRect.texture = vp.get_texture()
	$TextureRect.size = size

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			$FluidViewports.start_dye(Color.from_hsv(randf(), 0.5, 1.0))
		else:
			$FluidViewports.stop_dye()

	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		$FluidViewports.splat(event.position/size, event.relative)
