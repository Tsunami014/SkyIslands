extends RefCounted
class_name Items

static var inventory: Array = []

static func getImgRegion(name: String) -> Rect2:
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
