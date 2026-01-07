extends TextureRect
class_name Inv_item

@export var x: int
@export var y: int
@export var nam: String:
	set(newnam):
		if is_node_ready() and newnam != nam:
			texture.region = Items.getImgRegion(nam)
		nam = newnam
var select: bool = false:
	set(val):
		if is_node_ready() and val != select:
			var offs = 0 if val else 2
			set_position(Vector2i(x*20 + offs, y*20 + offs))
		select = val

func _ready() -> void:
	texture = AtlasTexture.new()
	texture.atlas = preload("res://assets/items.png")
	texture.region = Items.getImgRegion(nam)
	set_position(Vector2i(x*20 + 2, y*20 + 2))
