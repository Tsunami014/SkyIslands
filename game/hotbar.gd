@tool
extends TextureRect
class_name Hotbar

var index: int

func _ready() -> void:
	if !Engine.is_editor_hint():
		index = Items.maxHotbar
		Items.maxHotbar = index + 1

		Items.hotbarUpdate.connect(updateImg)

	texture = AtlasTexture.new()
	texture.atlas = preload("res://assets/gui.png")
	texture.region = Rect2(0, 0, 20, 20)

	var tex = TextureRect.new()
	tex.name = "Image"
	tex.texture = AtlasTexture.new()
	tex.texture.atlas = preload("res://assets/items.png")
	tex.set_position(Vector2i(2, 2))
	add_child(tex)
	tex.hide()
	updateImg()

func updateImg() -> void:
	texture.region = Rect2(20 if Items.hotbarSel == index else 0, 0, 20, 20)

	if Items.inventory.size() <= index:
		$Image.hide()
	else:
		$Image.texture.region = Items.getImgRegion(Items.inventory[index])
		$Image.show()
