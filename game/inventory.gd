extends Panel
var inv = []
var max_wid: int
var cursPos: int = 0
var lr_hold_time: int = 0
var ud_hold_time: int = 0
var first_sel: bool
const maxHold = 20

func _ready() -> void:
	hide()
	max_wid = int($Squares.size.x/20)
	UpdateVis()


func Tick() -> void:
	if len(inv) == 0:
		return
	tickMoveCurs()
	tickCraft()
	tickSelect()
	tickHotbar()

func tickMoveCurs() -> void:
	var lr = sign(Input.get_axis("move_left", "move_right"))
	if lr != 0:
		if lr_hold_time >= maxHold:
			cursPos += lr
		else:
			if lr_hold_time == 0:
				cursPos += lr
			lr_hold_time += 1
	else:
		lr_hold_time = 0
	var ud = sign(Input.get_axis("move_up", "move_down"))
	if ud != 0:
		if ud_hold_time >= maxHold:
			cursPos += ud * max_wid
		else:
			if ud_hold_time == 0:
				cursPos += ud * max_wid
			ud_hold_time += 1
	else:
		ud_hold_time = 0

	if cursPos <= 0:
		cursPos = 0
	elif cursPos >= len(inv):
		cursPos = len(inv) - 1

	$Squares/Selector.set_position(Vector2(
		(cursPos % max_wid) * 20,
		int(cursPos / max_wid) * 20
	))

func tickCraft() -> void:
	if not Input.is_action_just_pressed("craft"):
		return
	var offs = 0
	var toMerge: Array[Dictionary] = []
	var itslen = len(Items.inventory)
	for i in range(len(inv)):
		if inv[i].select:
			inv[i].select = false
			if i < itslen:
				toMerge.push_back(Items.inventory.pop_at(i-offs))
				offs += 1
	if offs == 0:
		return
	var toSel
	if offs == 1:
		var spl = Items.split(toMerge[0])
		Items.inventory.append_array(spl)
		toSel = spl[0]
	else:
		toSel = Items.merge(toMerge)
		Items.inventory.append(toSel)
	Items.sortInv()
	cursPos = Items.inventory.find(toSel)
	Update()

func tickSelect() -> void:
	if Input.is_action_just_pressed("action"):
		inv[cursPos].select = not inv[cursPos].select
		first_sel = inv[cursPos].select
	elif Input.is_action_pressed("action"):
		inv[cursPos].select = first_sel

	var prev
	if inv[cursPos].select:
		var toMerge: Array[Dictionary] = []
		var itslen = len(Items.inventory)
		for i in range(len(inv)):
			if inv[i].select and i < itslen:
				toMerge.push_back(Items.inventory[i])
		if len(toMerge) == 1:
			if toMerge[0]["contains"]:
				prev = {
					"realname": "Split items",
					"tile": toMerge[0]["tile"],
					"desc": "Will split into:\n"+", ".join(toMerge[0]["contains"].map(func(it): return it["name"]))
				}
			else:
				prev = toMerge[0]
		else:
			prev = Items.merge(toMerge)
	else:
		prev = inv[cursPos].data
	$Preview/Img.texture.region = Items.getImgRegion(prev["tile"])
	$Preview/Name.text = prev["realname"]
	$Preview/Desc.text = prev["desc"]

func tickHotbar() -> void:
	var change = false
	if Input.is_action_just_pressed("hotbar_left"):
		Items.hotbarSel = 0
		Items.hotbars[0] = inv[cursPos].data
		change = true
	if Input.is_action_just_pressed("hotbar_right"):
		Items.hotbarSel = len(Items.hotbars)-1
		Items.hotbars[Items.hotbarSel] = inv[cursPos].data
		change = true

	for i in range(len(Items.hotbars)):
		if Items.hotbars[i] not in Items.inventory:
			Items.hotbars[i] = {"tile": ""}
			change = true

	if change:
		%Player.hotbarUpdate.emit()


func Update() -> void:
	var myinvln = len(inv)
	var itsinvln = len(Items.inventory)
	for i in range(max(myinvln, itsinvln)):
		if i >= myinvln:
			var nit = Inv_item.new()
			nit.x = i % max_wid
			nit.y = int(i / max_wid)
			nit.data = Items.inventory[i]
			$Squares.add_child(nit)
			inv.append(nit)
		elif i >= itsinvln:
			inv[i].queue_free()
		else:
			inv[i].data = Items.inventory[i]
	inv = inv.slice(0, itsinvln)

	UpdateVis()

func UpdateVis():
	if len(inv) == 0:
		$Squares/Selector.hide()
		$Preview.hide()
	else:
		$Squares/Selector.show()
		$Preview.show()
