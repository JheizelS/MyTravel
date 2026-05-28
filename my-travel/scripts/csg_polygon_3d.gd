extends CSGPolygon3D

func _ready():
	var mat = ShaderMaterial.new()
	mat.shader = preload("res://scenes/testing.gdshader")
	mat.set_shader_parameter("road_tex", preload("res://assets/straight road (2).png"))
	mat.set_shader_parameter("scale", 0.1)
	self.material = mat
