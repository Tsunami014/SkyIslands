@tool
extends StaticBody2D
## A Map exported from ldtk
##
## Loads the map texture and collisions
class_name Map

var tex: Texture2D = null
@export var level_name: String = "":
	set(value):
		level_name = value
		var path = "res://map/simplified/%s/_composite.png" % level_name
		if FileAccess.file_exists(path):
			tex = load(path)
		else:
			tex = null

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

	var file = FileAccess.open("res://map/simplified/%s/TopTiles.csv" % level_name, FileAccess.READ)
	var toMerge = []

	var y = 0
	while !file.eof_reached():
		var line = file.get_csv_line()
		if line.size() >= 2:
			for x in line.size():
				if line[x] == "0":
					toMerge.append(get_tile_poly(x, y))
		y += 1

	var outPoly := PackedVector2Array(toMerge[0])
	var attempts := 100
	while !toMerge.is_empty() and (attempts > 0):
		outPoly = merge_poly_array_to(outPoly, toMerge)
		attempts -= 1
	if !toMerge.is_empty():
		printerr("Failed to merge in all the tiles!")

	var coll = CollisionPolygon2D.new()
	coll.polygon = outPoly
	coll.name = "Collisions"
	add_child(coll)

func merge_poly_array_to(merged : PackedVector2Array, toMerge: Array) -> PackedVector2Array:
	for tilePoly in toMerge:
		var merge_results = Geometry2D.merge_polygons(merged, tilePoly)
		if merge_results.size() == 1:
			merged = merge_results[0]
			toMerge.erase(tilePoly)
	return merged

func get_tile_poly(x, y) -> PackedVector2Array:
	var tl = Vector2(x,   y)   * 16
	var tr = Vector2(x+1, y)   * 16
	var br = Vector2(x+1, y+1) * 16
	var bl = Vector2(x,   y+1) * 16

	return PackedVector2Array([tl, tr, br, bl])


func _process(_delta: float) -> void:
	pass
