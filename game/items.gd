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
	#its = flatten(its)
	its.sort_custom(sortInteresting)

	var origIts = its
	var duplicates = 0
	var its2: Array[Dictionary] = []
	for it in its:
		if its2.has(it):
			duplicates += 1
		else:
			its2.append(it.duplicate_deep())
	its = its2

	var out = {}
	var xpect = {}
	var nameTags: Array[String] = []
	var tileTags: Array[String] = []
	var tints: Array[String] = []

	var alltags = {}
	for tag in data["tags"]:
		alltags[tag] = []
	for it in origIts:
		for t in it:
			if t in alltags:
				var i = it[t]
				if i != null and (i is not String or i != ""):
					alltags[t].append(i)

	if len(origIts) > 1:
		for r in data["recipes"]:
			var fail = false
			for tag in r["input"]:
				var required = len(alltags[tag]) # Check if there's extra not-blanks
				var blanks = len(origIts) - required
				var strtags = []
				for t in alltags[tag]:
					if t is String:
						strtags.append(t)
					elif t is float or t is int:
						strtags.append(str(float(t)))
					else:
						strtags.append(str(t))
				for req in r["input"][tag]:
					# This is where requirements are handled
					if req == ">":
						req = "#:,"
					elif req[0] == ">":
						req = "#"+req.substr(1)
					var nam: String
					var lowerAmnt
					var upperAmnt
					var idx = req.find(":")
					if idx != -1:
						nam = req.substr(0, idx)
						var part2 = req.substr(idx+1)
						idx = part2.find(",")
						lowerAmnt = part2.substr(0, idx)
						upperAmnt = part2.substr(idx+1)
					else:
						nam = req
						lowerAmnt = "1"
						upperAmnt = ""
					var curAmnt
					match nam:
						"_": curAmnt = blanks
						"&": curAmnt = len(origIts)
						"%", "#":
							curAmnt = required
							if nam == "#":
								if upperAmnt != "":
									required -= int(upperAmnt)
								else:
									required = 0
						"$":
							var uniques = []
							for t in strtags:
								if not uniques.has(t):
									uniques.append(t)
							curAmnt = len(uniques)
							required -= curAmnt
						_:
							curAmnt = strtags.count(nam)
							required -= curAmnt
					if lowerAmnt != "":
						if curAmnt < int(lowerAmnt):
							fail = true
							break
					if upperAmnt != "":
						if curAmnt > int(upperAmnt):
							fail = true
							break
				if fail:
					break
				if required > 0:
					fail = true
					break
			if not fail:
				for k in r["output"]:
					if k not in xpect:
						xpect[k] = r["output"][k]
				break

	if xpect == {} and len(its) == 1:
		xpect = its[0]

		var size
		match duplicates:
			0: size = ""
			1: size = "long"
			2: size = "big"
			3: size = "large"
			4: size = "huge"
			5: size = "enormous"
			6: size = "gigantic"
			7: size = "toweringly big"
			_: size = "astronomically huge"
		out["size"] = size
	else:
		out["size"] = ""

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
			# This is where tag combining happens
			match instr:
				"all":
					if not blnk:
						break
					var val = null
					for it in its:
						if tag in it:
							var i = it[tag]
							if i == null or (i is String and i == ""):
								pass
							elif val == null:
								val = i
							elif typeof(i) != typeof(val) or i != val:
								val = null
								break
					if val != null:
						t = val
				"interest":
					if not blnk:
						break
					for it in its:
						if tag in it:
							t = it[tag]
						if t != null and (t is not String or t != ""):
							break
				"set":
					if blnk: t = args
				"setn":
					if blnk: t = float(args)
				"combine":
					var a = args.split(",")
					if (not blnk) and "all" not in a and "override" not in a:
						break
					var outs: Array[String] = []
					for t2 in alltags[tag]:
						if t2 is String and t2 != "":
							if "dedup" not in a or not outs.has(t2):
								outs.push_back(t2)
					if instr == "all":
						t = " ".join(outs) + t
					else:
						t = " ".join(outs)
				"add":
					if len(alltags[tag]) > 0:
						t = 0
						for it in alltags[tag]:
							t += float(it)
				"addtile":
					if not blnk: tileTags.push_back(t)
				"tint":
					if t is String and t != "": tints.append(t)
		out[tag] = t

	for x in xpect:
		out[x] = xpect[x]
	for i in out:
		if i not in xpect:
			var dat = data["tags"][i]
			if "prefix" in dat:
				nameTags.push_back(out[i])

	var realname
	if len(nameTags) == 0:
		realname = out["name"]
	else:
		realname = " ".join(nameTags) + " " + out["name"]
	out["realname"] = realname.capitalize()
	var realtile
	while tileTags:
		realtile = " ".join(tileTags) + " " + out["tile"]
		if Items.data["tiles"].has(realtile):
			break
		tileTags.pop_back()
	if len(tileTags) == 0:
		realtile = out["tile"]
	out["realtile"] = realtile
	if len(tints) == 0:
		out["tint"] = Color(0, 0, 0, 0)
	else:
		var tot_r = 0
		var tot_g = 0
		var tot_b = 0
		for c in tints:
			var colour = Color(c)
			tot_r += colour.r
			tot_g += colour.g
			tot_b += colour.b

		var count = tints.size()
		out["tint"] = Color(
			tot_r / count,
			tot_g / count,
			tot_b / count
		)
	if len(origIts) > 1:
		out["contains"] = origIts
	else:
		out["contains"] = []
	return out
