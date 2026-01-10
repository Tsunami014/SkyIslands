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

	var alltags: Dictionary[String, Array] = {}
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
			var names = {}
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
					if req[0] == "(":
						var idx = req.find(")")+1
						var nam = req.substr(0, idx)
						var eq2 = req.substr(idx)
						var itidx = strtags.find(eq2)
						var done = false
						if itidx != -1:
							for it in origIts:
								if not it.has(tag):
									continue
								if itidx == 0:
									names[nam] = it
									done = true
									required -= 1
									break
								itidx -= 1
						if not done:
							fail = true
							break
					else:
						if req == ">":
							req = "#:,"
						elif req[0] == ">":
							req = "#"+req.substr(1)
						var lowerAmnt
						var upperAmnt
						var curAmnt
						var nam: String
						var idx = req.find(":")
						if idx != -1:
							nam = req.substr(0, idx)
							var part2 = req.substr(idx+1)
							if "," not in part2:
								part2 = part2+","+part2
							idx = part2.find(",")
							var lower = part2.substr(0, idx)
							if lower != "":
								lowerAmnt = int(lower)
							else:
								lowerAmnt = -1
							var upper = part2.substr(idx+1)
							if upper != "":
								upperAmnt = int(upper)
							else:
								upperAmnt = -1
						else:
							nam = req
							lowerAmnt = 1
							upperAmnt = -1
						match nam:
							"_": curAmnt = blanks
							"&": curAmnt = len(origIts)
							"%", "#":
								curAmnt = required
								if nam == "#":
									if upperAmnt != -1:
										required -= upperAmnt
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
								if upperAmnt != -1:
									curAmnt = min(curAmnt, upperAmnt)
								required -= curAmnt
						if lowerAmnt != -1:
							if curAmnt < lowerAmnt:
								fail = true
								break
						if upperAmnt != -1:
							if curAmnt > upperAmnt:
								fail = true
								break
				if required > 0:
					fail = true
				if fail:
					break
			if not fail:
				xpect["name prevolance"] = 2
				for k in r["output"]:
					if k not in xpect:
						var new = r["output"][k]
						if new[0] == "(":
							if names.has(new):
								new = names[new][k]
							else:
								continue
						xpect[k] = new
				break

	if xpect == {} and len(its) == 1:
		xpect = its[0]

		var size
		match duplicates:
			0: size = ""
			1: size = "big"
			2: size = "large"
			3: size = "huge"
			4: size = "enormous"
			5: size = "gigantic"
			6: size = "toweringly big"
			_: size = "astronomically huge"
		out["size"] = size
	else:
		out["size"] = ""

	var alls = {}
	for tag in alltags:
		var val = null
		for i in alltags[tag]:
			if i == null or (i is String and i == ""):
				pass
			elif val == null:
				val = i
			elif typeof(i) != typeof(val) or i != val:
				val = null
				break
		if val != null:
			alls[tag] = val

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
					if blnk and alls.has(tag):
						t = alls[tag]
				"interest":
					if not blnk:
						break
					t = alltags[tag][0]
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
				"max":
					if len(alltags[tag]) > 0:
						if args != "":
							var mx = -1
							for it in its:
								if tag in it and args in it:
									if it[args] > mx:
										t = it[tag]
										mx = it[args]
									elif it[args] == mx:
										t = ""
						else:
							if blnk:
								t = alltags[tag][0]
							else:
								t = float(t)
							for it in alltags[tag]:
								if it > t:
									t = it
				"tint":
					if t is String and t != "": tints.append(t)
		out[tag] = t

	for x in xpect:
		if x[0] == "_":
			out[x.substr(1)] = xpect[x]
		else:
			out[x] = xpect[x]
	if len(origIts) > 1:
		for t in out:
			if t in xpect or t not in data["tags"]:
				continue
			var o = out[t]
			if o == null or (o is String and o == ""):
				continue
			var success = t not in alls or alls[t] != o
			if not success:
				for it in its:
					if (not it.has(t)) or it[t] == null or (it[t] is String and it[t] == ""):
						success = true
						break
			if success:
				var dat = data["tags"][t]
				if "prefix" in dat:
					nameTags.push_back(o)
				if "addtile" in dat:
					tileTags.push_back(o)

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
