extends TextureRect
class_name Inv_item

@export var x: int
@export var y: int
@export var data: Dictionary:
	set(newdat):
		data = newdat
		if is_node_ready():
			texture.region = Items.getImgRegion(data["tile"])
var select: bool = false:
	set(val):
		if is_node_ready():
			var offs = 1 if val else 2
			set_position(Vector2i(x*20 + offs, y*20 + offs))
			set_instance_shader_parameter("outline_color", Color(0.626, 0.556, 0.121, 1.0) if val else Color())
		select = val

const ITEMS = preload("res://assets/items.png")
const SHADER = preload("res://outline.gdshader")
func _ready() -> void:
	texture = AtlasTexture.new()
	texture.atlas = ITEMS
	texture.region = Items.getImgRegion(data["tile"])
	material = ShaderMaterial.new()
	material.shader = SHADER
	select = select
