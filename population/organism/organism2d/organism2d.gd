class_name Organism2D extends CharacterBody2D
## TODO desc

signal canceled_moving_to_organism(target: Organism2D)
signal moved_to_organism2d(target: Organism2D)

var params: Organism2DParams = preload("./organism2d-default-params.tres")

var _is_moving_to_point := false
var _target_point: Vector2

var _is_moving_to_organism := false
var _target_organism: Organism2D

@onready var _shape := ($CollisionShape2D as CollisionShape2D).shape as CircleShape2D


func _ready() -> void:
	_target_point = get_random_point()
	_is_moving_to_point = true


func _physics_process(delta: float) -> void:
	_moving_to_organism()
	_moving_to_point(delta)
	move_and_slide()


func move_to_organism2d(organism: Organism2D) -> void:
	# До этого двигался к другому
	if _is_moving_to_organism:
		canceled_moving_to_organism.emit()
	_is_moving_to_organism = true
	_target_organism = organism


func get_random_point() -> Vector2:
	return Vector2(
		randf_range(params.world_left_border, params.world_right_border),
		randf_range(params.world_upper_border, params.world_lower_border)
	)


func _moving_to_organism() -> void:
	if not _is_moving_to_organism:
		return

	_target_point = _target_organism.global_position
	_is_moving_to_point = true

	var dist: float = global_position.distance_to(_target_organism.global_position)
	if dist <= params.move_to_organism_distance + _shape.radius:
		_is_moving_to_organism = false
		moved_to_organism2d.emit(_target_organism)
		_target_point = get_random_point()


func _moving_to_point(delta: float) -> void:
	if not _is_moving_to_point:
		return

	var diff : Vector2 = _target_point - global_position
	var direction: Vector2 = diff.normalized()
	velocity = params.speed * direction

	if (velocity * delta).length() > diff.length():
		velocity = Vector2.ZERO
		global_position = _target_point
		_target_point = get_random_point()
