extends Area2D
@export var item: String
@export var hide: bool = false
var done: bool = false

func _on_body_entered(body):
	if (not done) and body is Player:
		_setColour(Color(0.549, 0.563, 0.0, 1.0))
func _on_body_exited(body):
	if (not done) and body is Player:
		_setColour(Color(0.0, 0.0, 0.0, 1.0))

func _setColour(col: Color):
	$Img.set_instance_shader_parameter("outline_color", col)

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if (not done) and Input.is_action_just_pressed("collect"):
		var bodies = get_overlapping_bodies()
		for body in bodies:
			if body is Player:
				done = true
				%Player.items.append(item)
				if hide:
					$Img.hide()
				else:
					_setColour(Color(0.0, 0.0, 0.0, 1.0))
					$Img.region_rect.position.x += $Img.region_rect.size.x
