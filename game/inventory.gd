extends Panel
var inv = []
var max_wid: int

func _ready() -> void:
	hide()
	%Player.InventoryTick.connect(_tick)
	Items.inventoryUpdate.connect(_update)
	max_wid = int($Squares.size.x/20)

func _tick() -> void:
	pass

func _update() -> void:
	var myinvln = len(inv)
	var itsinvln = len(Items.inventory)
	for i in range(max(myinvln, itsinvln)):
		if i >= myinvln:
			var nit = Inv_item.new()
			nit.x = i % max_wid
			nit.y = int(i / max_wid)
			nit.nam = Items.inventory[i]
			$Squares.add_child(nit)
			inv.append(nit)
		elif i >= itsinvln:
			inv[i].queue_free()
		else:
			inv[i].nam = Items.inventory[i]
	inv = inv.slice(0, itsinvln)
