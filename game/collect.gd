extends Area2D

func _on_body_entered(body):
	if body is Player:
		_setColour(Color(0.549, 0.563, 0.0, 1.0))
func _on_body_exited(body):
	if body is Player:
		_setColour(Color(0.0, 0.0, 0.0, 1.0))

func _setColour(col: Color):
	var material = $Img.material
	if material is ShaderMaterial:
		material.set_shader_parameter("outline_color", col)

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass
