@tool
extends StaticBody2D
## A Map exported from ldtk
##
## Loads the map texture and collisions
##
## Please note when adding new csv files ensure they are imported as 'keep file as is' (the tab next to scene)
class_name Map

var tex: Texture2D = null
@export var level_name: String = "":
	set(value):
		level_name = value
		var path = "res://map/simplified/%s/_composite.png" % level_name
		tex = load(path)
		if not tex:
			push_error("Failed to load texture at: " + path)

func _get_configuration_warnings() -> PackedStringArray:
	if not tex:
		return PackedStringArray(["Level name not found: "+level_name])
	return PackedStringArray([])

func _ready() -> void:
	var spr = Sprite2D.new()
	spr.name = "Image"
	spr.texture = tex
	spr.centered = false
	spr.z_index = -1
	add_child(spr)

	var path = "res://map/simplified/%s/TopTiles.csv" % level_name
	if not FileAccess.file_exists(path):
		push_error("CSV File not found at: " + path)
		return
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open file: " + path)
		return

	var toMerge = []

	var y = 0
	while !file.eof_reached():
		var line = file.get_csv_line()
		if line.size() >= 2:
			for x in line.size():
				if line[x] == "0" or line[x] == "3":
					toMerge.append(get_tile_poly(x, y))
		y += 1

	var i = 0
	while i < len(toMerge):
		var merged = false
		for j in range(i+1, len(toMerge)):
			if j == i:
				continue
			var merge = Geometry2D.merge_polygons(toMerge[i], toMerge[j])
			if merge.size() == 1:
				toMerge[i] = merge[0]
				toMerge.remove_at(j)
				merged = true
				break
		if not merged:
			i += 1

	for poly in toMerge:
		var coll = CollisionPolygon2D.new()
		coll.polygon = poly
		add_child(coll)

func get_tile_poly(x, y) -> PackedVector2Array:
	var tl = Vector2(x,   y)   * 16
	var tr = Vector2(x+1, y)   * 16
	var br = Vector2(x+1, y+1) * 16
	var bl = Vector2(x,   y+1) * 16

	return PackedVector2Array([tl, tr, br, bl])


func _process(_delta: float) -> void:
	pass
