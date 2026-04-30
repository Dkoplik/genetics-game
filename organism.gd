extends CharacterBody2D

@export var speed: float = 100.0
var _target_point: Vector2


func _ready() -> void:
	_target_point = get_random_point()


func _process(delta: float) -> void:
	var vec_to_target: Vector2 = _target_point - position
	if (vec_to_target.length() < 10.0):
		_target_point = get_random_point()

	var direction_to_target: Vector2 = position.direction_to(_target_point)
	velocity = speed * direction_to_target
	move_and_slide()


func get_random_point() -> Vector2:
	return Vector2(randf_range(0.0, 1000.0), randf_range(000.0, 1000.0))
