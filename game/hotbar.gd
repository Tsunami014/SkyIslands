@tool
extends TextureRect
class_name Hotbar

var index: int

const GUI = preload("res://assets/gui.png")
const ITEMS = preload("res://assets/items.png")
const SHADER = preload("res://outline.gdshader")
func _ready() -> void:
	if !Engine.is_editor_hint():
		index = len(Items.hotbars)
		Items.hotbars.append({"realtile": "", "tint": Color(0,0,0,0)})
		%Player.hotbarUpdate.connect(updateImg)

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
	tex.set_instance_shader_parameter("outline_colour", Color())

	add_child(tex)
	updateImg()

func updateImg() -> void:
	texture.region = Rect2(20 if Items.hotbarSel == index else 0, 0, 20, 20)

	$Image.texture.region = Items.getImgRegion(Items.hotbars[index]["realtile"])
	$Image.set_instance_shader_parameter("tint_colour", Items.hotbars[index]["tint"])
