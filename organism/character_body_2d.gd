extends CharacterBody2D

signal collided()

var speed: float = 200.0


func _physics_process(_delta: float) -> void:
	var is_collided: bool = move_and_slide()
	if is_collided:
		collided.emit()
