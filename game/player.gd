extends CharacterBody2D
class_name Player

signal hotbarUpdate()

@export var speed = 80 # pixels/sec
var inventory = false

func _physics_process(_delta):
	if Input.is_action_just_pressed("hotbar_toggle"):
		Items.hotbarSel = (Items.hotbarSel + 1) % len(Items.hotbars)
		Items.hotbarUpdate.emit()

	if Input.is_action_just_pressed("inventory"):
		inventory = not inventory
		if inventory:
			%Inventory.show()
			$AnimatedSprite2D.animation = "Idle"
		else:
			%Inventory.hide()
	if inventory:
		%Inventory.Tick()
		return

	if Input.is_action_just_pressed("hotbar_left"):
		Items.hotbarSel = 0
		Items.hotbarUpdate.emit()
	if Input.is_action_just_pressed("hotbar_right"):
		Items.hotbarSel = len(Items.hotbars)-1
		Items.hotbarUpdate.emit()

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed

	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	move_and_slide()

	if velocity.x != 0 or velocity.y != 0:
		$AnimatedSprite2D.animation = "Walk"
		$AnimatedSprite2D.flip_h = velocity.x > 0
	else:
		$AnimatedSprite2D.animation = "Idle"
