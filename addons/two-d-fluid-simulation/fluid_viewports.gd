extends Node

var dyesz
var rectsz
var bloomsz
const lastpressureiteration = 19
var lastpressureviewport : Viewport

func _ready():
	assert (ProjectSettings.get_setting("rendering/renderer/rendering_method") == "forward_plus")
	# make sure that all the components are wired up correctly
	assert ($VelocityViewport/Sprite2D.material.get_shader_parameter("splattexture").viewport_path == NodePath("SplatVelocityViewport"))
	assert ($CurlViewport/Sprite2D.texture.viewport_path == NodePath("VelocityViewport"))
	assert ($VorticityViewport/Sprite2D.texture.viewport_path == NodePath("CurlViewport"))
	assert ($VorticityViewport/Sprite2D.material.get_shader_parameter("velocitytexture").viewport_path == NodePath("VelocityViewport"))
	assert ($DivergenceViewport/Sprite2D.texture.viewport_path == NodePath("VorticityViewport"))
	assert ($PressureNode/PressureViewport/Sprite2D.material.get_shader_parameter("divergencetexture").viewport_path == NodePath("DivergenceViewport"))
	assert ($AdvectionViewport/Sprite2D.texture.viewport_path == NodePath("GradientViewport"))
	assert ($DyeViewport/Sprite2D.material.get_shader_parameter("splattexture").viewport_path == NodePath("SplatDyeViewport"))
	assert ($DyeAdvectionViewport/Sprite2D.texture.viewport_path == NodePath("DyeViewport"))
	assert ($DyeAdvectionViewport/Sprite2D.material.get_shader_parameter("velocitytexture").viewport_path == NodePath("AdvectionViewport"))
	
	for vp in [ $SplatVelocityViewport, $SplatDyeViewport ]:
		assert (vp.render_target_clear_mode == SubViewport.CLEAR_MODE_NEVER)
		assert (vp.render_target_update_mode == SubViewport.UPDATE_ONCE)
		assert (vp.disable_3d and vp.use_hdr_2d)
	for vp in [ $VelocityViewport, $CurlViewport, $VorticityViewport, $DivergenceViewport, $PressureNode/PressureViewport, $GradientViewport, $AdvectionViewport, $DyeViewport, $DyeAdvectionViewport ]:
		assert (vp.render_target_clear_mode == SubViewport.CLEAR_MODE_NEVER)
		assert (vp.render_target_update_mode == SubViewport.UPDATE_WHEN_PARENT_VISIBLE)
		assert (vp.disable_3d)
		assert (vp.use_hdr_2d == (vp != $PressureNode/PressureViewport))
		#vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	var pvshd = $PressureNode/PressureViewport/Sprite2D.get_material()
	var dpvshd = pvshd.duplicate()
	pvshd.set_shader_parameter("pressurefac", 0.8)
	dpvshd.set_shader_parameter("pressurefac", 1.0)
	$VorticityViewport/Sprite2D.get_material().set_shader_parameter("curl", 0.2*30.0)
	$AdvectionViewport/Sprite2D.get_material().set_shader_parameter("dissipation", 0.2)
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

func update_size(size):
	var sizef10 = Vector2(round(size.x/10)*10, round(size.y/10)*10)
	if size != sizef10:
		print("Rounding size from ", size, " to ", sizef10)
	dyesz = sizef10   # these are very sensitive to misalignment
	rectsz = sizef10*0.1
	bloomsz = sizef10*0.2
	
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

	for v in $PressureNode.get_children():
		v.size = rectsz
		v.get_node("Sprite2D").position = rectsz/2
		var mat = v.get_node("Sprite2D").get_material()
		mat.set_shader_parameter("texelsize", Vector2.ONE/rectsz)
		#mat.set_shader_parameter("pressurefac", 0.8 if v.name == "PressureViewport" else 1.0)
		assert (v.render_target_clear_mode == v.CLEAR_MODE_NEVER)
		#assert (v.render_target_update_mode == v.UPDATE_ONCE)

func splat(pos, vel):
	var mat1 = $SplatVelocityViewport/Sprite2D.get_material()
	mat1.set_shader_parameter("point", pos)
	mat1.set_shader_parameter("color", 60*Vector3(vel.x, vel.y, 0.0))
	mat1.set_shader_parameter("radius", 0.001)
	$SplatVelocityViewport.set_update_mode(SubViewport.UPDATE_ONCE)

	var mat2 = $SplatDyeViewport/Sprite2D.get_material()
	#mat2.set_shader_parameter("color", Vector3(0.0, 0.0, 1.0))
	mat2.set_shader_parameter("point", pos)
	mat2.set_shader_parameter("radius", 0.002)
	$SplatDyeViewport.set_update_mode(SubViewport.UPDATE_ONCE)

func start_dye(color):
	var mat2 = $SplatDyeViewport/Sprite2D.get_material()
	mat2.set_shader_parameter("color", color)
	mat2.set_shader_parameter("radius", 0.001)

func stop_dye():
	var mat1 = $SplatVelocityViewport/Sprite2D.get_material()
	mat1.set_shader_parameter("color", Color(0,0,0,0))
	var mat2 = $SplatDyeViewport/Sprite2D.get_material()
	mat2.set_shader_parameter("color", Color(0,0,0,0))
	$SplatVelocityViewport.set_update_mode(SubViewport.UPDATE_ONCE)
	$SplatDyeViewport.set_update_mode(SubViewport.UPDATE_ONCE)


# see https://github.com/godotengine/godot/pull/51709 for details
# for doing the HDR in full floating point (there's an option in godot3 for this)

func _process(delta):
	var dt = delta
	$VorticityViewport/Sprite2D.get_material().set_shader_parameter("dt", dt)
	$AdvectionViewport/Sprite2D.get_material().set_shader_parameter("dt", dt)

	# Loop back copies of textures from outputs to inputs
	$VelocityViewport/Sprite2D.texture.set_image($AdvectionViewport.get_texture().get_image())
	$PressureNode/PressureViewport/Sprite2D.texture.set_image(lastpressureviewport.get_texture().get_image())
	$DyeViewport/Sprite2D.texture.set_image($DyeAdvectionViewport.get_texture().get_image())
