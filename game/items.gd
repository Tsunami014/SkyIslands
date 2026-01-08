extends Node

signal inventoryUpdate()
signal hotbarUpdate()

var inventory: Array = []
var hotbars: Array = []
var hotbarSel: int = 0
var data: Dictionary

func _parseJsonData() -> void:
	var file = FileAccess.open("res://data.json", FileAccess.READ)
	if FileAccess.get_open_error() != OK:
		print("Error opening json data file!")
	var content = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		data = json.data
	else:
		print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())

func _ready() -> void:
	inventoryUpdate.connect(hotbarUpdate.emit)
	_parseJsonData()


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

func addToInv(nam: String) -> void:
	inventory.append(nam)
	inventory.sort_custom(func(a, b):
		return a < b
	)
