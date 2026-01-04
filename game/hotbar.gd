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
	updateImg()


func _process(_delta: float) -> void:
	updateImg()

func updateImg() -> void:
	if Items.inventory.size() <= index:
		$Image.hide()
	else:
		$Image.show()
		$Image.texture.region = Items.getImgRegion(Items.inventory[index])
