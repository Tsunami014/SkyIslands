extends CollisionPolygon2D

@export_file_path("*.csv") var csv_path

func _ready() -> void:
	var file = FileAccess.open(csv_path, FileAccess.READ)
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

	polygon = outPoly

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
