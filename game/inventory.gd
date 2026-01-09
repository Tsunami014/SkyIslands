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
	tickInput()

func tickInput() -> void:
	if len(inv) == 0:
		return
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


	if Input.is_action_just_pressed("select"):
		inv[cursPos].select = not inv[cursPos].select
		first_sel = inv[cursPos].select
	elif Input.is_action_pressed("select"):
		inv[cursPos].select = first_sel
	$Preview/Img.texture.region = inv[cursPos].texture.region
	$Preview/Name.text = inv[cursPos].nam.capitalize()
	$Preview/Desc.text = Items.data["items"][inv[cursPos].nam]["desc"]


	var change = false
	if Input.is_action_just_pressed("hotbar_left"):
		Items.hotbarSel = 0
		Items.hotbars[0] = inv[cursPos].nam
		change = true
	if Input.is_action_just_pressed("hotbar_right"):
		Items.hotbarSel = len(Items.hotbars)-1
		Items.hotbars[Items.hotbarSel] = inv[cursPos].nam
		change = true

	for i in range(len(Items.hotbars)):
		if Items.hotbars[i] not in Items.inventory:
			Items.hotbars[i] = ""
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
			nit.nam = Items.inventory[i]
			$Squares.add_child(nit)
			inv.append(nit)
		elif i >= itsinvln:
			inv[i].queue_free()
		else:
			inv[i].nam = Items.inventory[i]
	inv = inv.slice(0, itsinvln)

	UpdateVis()

func UpdateVis():
	if len(inv) == 0:
		$Squares/Selector.hide()
		$Preview.hide()
	else:
		$Squares/Selector.show()
		$Preview.show()
