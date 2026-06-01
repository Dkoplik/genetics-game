extends CharacterBody2D

signal collided()

var _has_target := false
var _physics_delta: float = 1.0 / 60.0


func _physics_process(delta: float) -> void:
	_physics_delta = delta

	var is_collided: bool = move_and_slide()
	if is_collided:
		collided.emit()

	if _has_target:
		_has_target = false
		velocity = Vector2.ZERO


## Выполнить движение к точке [param target] в этом кадре.
func move_to_point(target: Vector2, speed: float, rotation_speed: float) -> void:
	var move_accel: float = speed / 4.0

	var vec_to_target: Vector2 = target - global_position
	var direction_to_target: Vector2 = vec_to_target.normalized()

	# move
	var desired_velocity: Vector2 = speed * direction_to_target
	velocity = velocity.move_toward(desired_velocity, move_accel)

	# rotate
	var cur_direction: Vector2 = Vector2.RIGHT.rotated(rotation)
	var desired_angle: float = rad_to_deg(cur_direction.angle_to(direction_to_target))
	var desired_diff: float = desired_angle - rotation_degrees

	var max_angle_diff: float = rotation_speed * _physics_delta
	var angle_diff: float = clampf(desired_diff, -max_angle_diff, max_angle_diff)
	rotation_degrees += angle_diff
