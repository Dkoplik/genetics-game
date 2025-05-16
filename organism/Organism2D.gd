class_name Organism2D extends CharacterBody2D
## TODO desc

signal moved_to_point

var params: Resource # Should make custom resource
var speed: float = 10.0

var _target_point: Vector2
var is_moving := true
var _is_moving_to_organism := false
var _target_organism: Organism


func _physics_process(delta: float) -> void:
	if not is_moving:
		return

	var diff : Vector2 = _target_point - position
	if diff.is_zero_approx():
		moved_to_point.emit()
		is_moving = false
		return

	var direction: Vector2 = diff.normalized()
	velocity = min(speed, diff.length()) * direction * delta
	move_and_slide()


func move_to_point(point: Vector2) -> void:
	_target_point = point
	is_moving = true


func move_to_organism(organism: Organism) -> void:
	pass


func _move(delta: float) -> void:
	if _target_point == null:
		return
