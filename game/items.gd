extends Node

var inventory: Array[Dictionary] = []
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
	_parseJsonData()


func getImgRegion(name: String) -> Rect2:
	if name == "":
		return Rect2(0, 0, 0, 0)
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
	var dat = data["items"][nam]
	dat["name"] = nam.capitalize()
	dat["tile"] = nam
	dat["contains"] = []
	inventory.append(dat)
	sortInv()
func sortInv() -> void:
	inventory.sort_custom(func(a, b):
		if a["contains"]:
			return true
		if b["contains"]:
			return false
		return a["name"] < b["name"]
	)

func split(dat: Dictionary) -> Array[Dictionary]:
	if dat["contains"]:
		return dat["contains"]
	return [dat]

func merge(its: Array[Dictionary]) -> Dictionary:
	return {
		"name": " & ".join(its.map(func(it): return it["name"])),
		"tile": "null",
		"desc": "Many things",
		"contains": its
	}
