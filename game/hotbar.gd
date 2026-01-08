@tool
extends TextureRect
class_name Hotbar

var index: int

const GUI = preload("res://assets/gui.png")
const ITEMS = preload("res://assets/items.png")
const SHADER = preload("res://outline.gdshader")
func _ready() -> void:
	if !Engine.is_editor_hint():
		index = Items.maxHotbar
		Items.maxHotbar = index + 1

		Items.hotbarUpdate.connect(updateImg)

	texture = AtlasTexture.new()
	texture.atlas = GUI
	texture.region = Rect2(0, 0, 20, 20)

	var tex = TextureRect.new()
	tex.name = "Image"
	tex.texture = AtlasTexture.new()
	tex.texture.atlas = ITEMS
	tex.set_position(Vector2i(2, 2))

	tex.material = ShaderMaterial.new()
	tex.material.shader = SHADER
	tex.set_instance_shader_parameter("outline_color", Color())

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
