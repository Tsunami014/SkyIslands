extends Node

signal inventoryUpdate()
signal hotbarUpdate()

static var inventory: Array = []
static var hotbarSel: int = 0
static var maxHotbar: int = 0

func getImgRegion(name: String) -> Rect2:
	var vec = null
	match name:
		"apple":
			vec = Vector2i(1, 0)
		"rock":
			vec = Vector2i(2, 0)
		"grass":
			vec = Vector2i(3, 0)

	if vec:
		return Rect2(vec * 16, Vector2(16, 16))
	return Rect2(0, 0, 16, 16)

func _ready() -> void:
	inventoryUpdate.connect(hotbarUpdate.emit)
