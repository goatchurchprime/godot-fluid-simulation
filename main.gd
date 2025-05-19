extends Control


var dyesz
var rectsz
const lastpressureiteration = 19
var lastpressureviewport : Viewport

func updatesize():
	dyesz = size
	rectsz = size*0.1
	print("Rectsz ", rectsz)
	print("Dyesz ", size)
	#$TextureRect.size = rectsz
	$SplatVelocityViewport/Sprite2D.texture.width = rectsz.x
	$SplatVelocityViewport/Sprite2D.texture.height = rectsz.y
	$SplatDyeViewport/Sprite2D.texture.width = dyesz.x
	$SplatDyeViewport/Sprite2D.texture.height = dyesz.y
	for v in get_children():
		if v is SubViewport:
			var mat = v.get_node("Sprite2D").get_material()
			mat.set_shader_parameter("aspectRatio", rectsz.x/rectsz.y)
			if v.name.contains("Dye"):
				v.size = dyesz
				v.get_node("Sprite2D").position = dyesz/2
			else:
				v.size = rectsz
				v.get_node("Sprite2D").position = rectsz/2
			mat.set_shader_parameter("texelsize", Vector2.ONE/rectsz)
			assert (v.render_target_clear_mode == v.CLEAR_MODE_NEVER)
			#assert (v.render_target_update_mode == v.UPDATE_ONCE)
			assert (v.disable_3d)
			assert (v.use_hdr_2d)
			#print(v.get_path(), mat.get_shader_parameter("texelsize"))

	for v in $PressureNode.get_children():
		v.size = rectsz
		v.get_node("Sprite2D").position = rectsz/2
		var mat = v.get_node("Sprite2D").get_material()
		mat.set_shader_parameter("texelsize", Vector2.ONE/rectsz)
		#mat.set_shader_parameter("pressurefac", 0.8 if v.name == "PressureViewport" else 1.0)
		assert (v.render_target_clear_mode == v.CLEAR_MODE_NEVER)
		#assert (v.render_target_update_mode == v.UPDATE_ONCE)
		assert (v.disable_3d)

func _ready():
	var pvshd = $PressureNode/PressureViewport/Sprite2D.get_material()
	print(pvshd)
	pvshd.set_shader_parameter("pressurefac", 0.8)
	var dpvshd = pvshd.duplicate()
	dpvshd.set_shader_parameter("pressurefac", 1.0)
	print(pvshd.get_shader_parameter("pressurefac"))
	for i in range(1, lastpressureiteration+1):
		var nname = "PressureViewport%d" % i
		var pv = get_node_or_null(nname)
		var vtprev = $PressureNode.get_child(i - 1).get_texture()
		if pv == null:
			pv = $PressureNode/PressureViewport.duplicate()
			pv.name = "PressureViewport%d" % i
			$PressureNode.add_child(pv)
			pv.get_node("Sprite2D").texture = vtprev
			pv.get_node("Sprite2D").set_material(dpvshd)
		#vtprev.set_viewport_path_in_scene(get_path_to($PressureNode.get_child(i - 1)))
		lastpressureviewport = pv
	$GradientViewport/Sprite2D.texture = lastpressureviewport.get_texture()
	_on_option_button_item_selected(0)
	updatesize()
	
	await get_tree().create_timer(0.1).timeout

	var mat1 = $SplatVelocityViewport/Sprite2D.get_material()
	var mat2 = $SplatDyeViewport/Sprite2D.get_material()
	for i in range(10):
		mat2.set_shader_parameter("color", Color.from_hsv(randf(), 0.5, 1.0)*3)
		splat(Vector2(size.x*randf(), size.y*randf()), Vector2(randf_range(-19,19),randf_range(-19,19)))
		$SplatVelocityViewport.set_update_mode(SubViewport.UPDATE_ONCE)
		$SplatDyeViewport.set_update_mode(SubViewport.UPDATE_ONCE)
		await get_tree().process_frame
	mat1.set_shader_parameter("color", Color(0,0,0,0))
	mat2.set_shader_parameter("color", Color(0,0,0,0))
	$SplatVelocityViewport.set_update_mode(SubViewport.UPDATE_ONCE)
	$SplatDyeViewport.set_update_mode(SubViewport.UPDATE_ONCE)

func _on_option_button_item_selected(index):
	var selviewport = $OptionButton.get_item_text(index)
	if selviewport.begins_with("PressureViewport"):
#		$TextureRect.texture = lastpressureviewport.get_texture()
		var vp = $PressureNode.get_node(selviewport)
		var vpt = vp.get_node("Sprite2D").get_texture()
		$TextureRect.texture = vp.get_texture()
	else:
		$TextureRect.texture = get_node(selviewport).get_texture()
	$TextureRect.size = size

func splat(pos, vel):
	print(pos, vel)
	var mat1 = $SplatVelocityViewport/Sprite2D.get_material()
	mat1.set_shader_parameter("point", pos/size)
	mat1.set_shader_parameter("color", 60*Vector3(vel.x, vel.y, 0.0))
	mat1.set_shader_parameter("radius", 0.001)
	$SplatVelocityViewport.set_update_mode(SubViewport.UPDATE_ONCE)

	var mat2 = $SplatDyeViewport/Sprite2D.get_material()
	#mat2.set_shader_parameter("color", Vector3(0.0, 0.0, 1.0))
	mat2.set_shader_parameter("point", pos/size)
	mat2.set_shader_parameter("radius", 0.002)
	$SplatDyeViewport.set_update_mode(SubViewport.UPDATE_ONCE)

func _gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		var mat2 = $SplatDyeViewport/Sprite2D.get_material()
		mat2.set_shader_parameter("color", Color.from_hsv(randf(), 0.5, 1.0))
		mat2.set_shader_parameter("radius", 0.001)
	elif event is InputEventMouseButton and not event.is_pressed():
		var mat1 = $SplatVelocityViewport/Sprite2D.get_material()
		mat1.set_shader_parameter("color", Color(0,0,0,0))
		var mat2 = $SplatDyeViewport/Sprite2D.get_material()
		mat2.set_shader_parameter("color", Color(0,0,0,0))
		$SplatVelocityViewport.set_update_mode(SubViewport.UPDATE_ONCE)
		$SplatDyeViewport.set_update_mode(SubViewport.UPDATE_ONCE)
		
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		splat(event.position, event.relative)

# see https://github.com/godotengine/godot/pull/51709 for details
# for doing the HDR in full floating point (there's an option in godot3 for this)

func _process(delta):
	var dt = delta
	$VorticityViewport/Sprite2D.get_material().set_shader_parameter("dt", dt)
	$VorticityViewport/Sprite2D.get_material().set_shader_parameter("curl", 0.2*30.0)
	$AdvectionViewport/Sprite2D.get_material().set_shader_parameter("dt", dt)
	$AdvectionViewport/Sprite2D.get_material().set_shader_parameter("dissipation", 0.2)

	# Loop back copies of textures from outputs to inputs
	$VelocityViewport/Sprite2D.texture.set_image($AdvectionViewport.get_texture().get_image())
	$PressureNode/PressureViewport/Sprite2D.texture.set_image(lastpressureviewport.get_texture().get_image())
	$DyeViewport/Sprite2D.texture.set_image($DyeAdvectionViewport.get_texture().get_image())
