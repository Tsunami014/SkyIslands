extends CharacterBody2D
class_name Player

@export var speed = 80 # pixels/sec

func _ready() -> void:
	pass

func _physics_process(_delta):
	if Input.is_action_just_pressed("change_hotbar"):
		Items.hotbarSel = (Items.hotbarSel + 1) % Items.maxHotbar
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
