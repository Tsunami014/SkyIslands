extends TextureRect

@export var index: int

func _ready() -> void:
	var tex = TextureRect.new()
	tex.name = "Image"
	var imgs = AtlasTexture.new()
	imgs.atlas = preload("res://assets/items.png")
	imgs.region = Rect2(0, 0, 16, 16)
	tex.texture = imgs
	tex.set_position(Vector2i(2, 2))
	add_child(tex)


func _process(delta: float) -> void:
	if Items.inventory.size() <= index:
		$Image.texture.region.position.x = 0
	else:
		$Image.texture.region.position.x = 16
