extends Control


func _ready() -> void:
	hide()
	%Player.InventoryTick.connect(_tick)

func _tick() -> void:
	pass

func _process(_delta: float) -> void:
	pass
