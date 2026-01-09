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
		return Rect2(0, 0, -1, -1)
	if name in data["tiles"]:
		var pos = data["tiles"][name]
		return Rect2(pos[0] * 16, pos[1] * 16, 16, 16)
	return Rect2(0, 0, 16, 16)

func _defaultKey(dat: Dictionary, nam: String) -> Dictionary:
	var dat2 = dat.duplicate()
	dat2.erase("type")
	dat2["name"] = nam
	dat2["tile"] = nam
	dat2["contains"] = []
	return merge([dat2])

func addToInv(nam: String) -> void:
	var dat: Dictionary = data["items"][nam]
	match dat["type"]:
		"combined":
			inventory.append(merge(dat["items"].map(
				func(it): return _defaultKey(data["items"][it], it)
			)))
		"resource":
			inventory.append(_defaultKey(dat, nam))
		_: return
	sortInv()

func sortInteresting(a, b) -> bool:
	var diff = len(a["contains"]) - len(b["contains"])
	if diff != 0:
		return diff > 0

	var diff2 = a["interest"] - b["interest"]
	if diff2 != 0:
		return diff2 > 0

	return a["name"] < b["name"]

func sortInv() -> void:
	inventory.sort_custom(sortInteresting)

func split(dat: Dictionary) -> Array[Dictionary]:
	if dat["contains"]:
		return dat["contains"]
	return [dat]

func flatten(its: Array[Dictionary]) -> Array[Dictionary]:
	var allits: Array[Dictionary] = []
	for it in its:
		if it["contains"]:
			allits.append_array(flatten(it["contains"]))
		else:
			allits.append(it)
	return allits
func merge(its: Array[Dictionary]) -> Dictionary:
	its = flatten(its)
	its.sort_custom(sortInteresting)
	var out = its[0] if len(its) == 1 else {}

	var nameTags: Array[String] = []
	var tileTags: Array[String] = []

	for tag in data["tags"]:
		var t = out[tag] if tag in out else ""
		for todo in data["tags"][tag]:
			var instr: String
			var args: String
			var idx = todo.find("=")
			if idx != -1:
				instr = todo.substr(0, idx)
				args = todo.substr(idx+1)
			else:
				instr = todo
				args = ""
			var blnk = t == null or (t is String and t == "")
			match instr:
				"all":
					pass
				"interest":
					if blnk:
						for it in its:
							if tag in it:
								t = it[tag]
							if t != null and (t is not String or t != ""):
								break
				"set":
					if blnk: t = args
				"setn":
					if blnk: t = float(args)
				"prefix":
					nameTags.push_back(t)
				"combine":
					var a = args.split(",")
					if blnk or "all" in a or "override" in a:
						var outs: Array[String] = []
						for it in its:
							var t2 = it[tag]
							if t2 is String and t2 != "":
								if "dedup" not in a or not outs.has(t2):
									outs.push_back(t2)
						if instr == "all":
							t = " ".join(outs) + t
						else:
							t = " ".join(outs)
		out[tag] = t

	var realname
	if len(nameTags) == 0:
		realname = out["name"]
	else:
		realname = " ".join(nameTags) + " " + out["name"]
	out["realname"] = realname.capitalize()
	out["realtile"] = " ".join(tileTags) + out["tile"]
	if len(its) > 1:
		out["contains"] = its
	else:
		out["contains"] = []
	return out
