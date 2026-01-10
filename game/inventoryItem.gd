extends TextureRect
class_name Inv_item

@export var x: int
@export var y: int
@export var data: Dictionary:
	set(newdat):
		data = newdat
		if is_node_ready():
			texture.region = Items.getImgRegion(data["realtile"])
			set_instance_shader_parameter("tint_colour", data["tint"])
var select: bool = false:
	set(val):
		if is_node_ready():
			set_instance_shader_parameter("outline_colour", Color(0.62, 0.41, 0.2, 1.0) if val else Color())
			set_instance_shader_parameter("bg_colour", Color(0.82, 0.533, 0.22, 0.392) if val else Color(0.0, 0.0, 0.0, 0.0))
		select = val

const ITEMS = preload("res://assets/items.png")
const MATERIAL = preload("res://item_material.tres")
func _ready() -> void:
	texture = AtlasTexture.new()
	texture.atlas = ITEMS
	material = MATERIAL.duplicate()
	set_position(Vector2i(x*20 + 2, y*20 + 2))
	data = data
	select = select
