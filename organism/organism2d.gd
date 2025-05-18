class_name Organism2D extends CharacterBody2D
## TODO desc

signal moved_to_point
signal moved_to_organism(organism: Organism2D)

var params: Organism2DParams = preload("res://organism/organism2d-params.tres")
var speed: float = 200.0

var _is_moving := false
var _target_point: Vector2

var _is_moving_to_organism := false
var _target_organism: Organism2D


func _ready() -> void:
	start_random_movement()


func _physics_process(delta: float) -> void:
	_move(delta)
	move_and_slide()


func move_to_point(point: Vector2) -> void:
	_target_point = point
	_is_moving = true


func move_to_organism(organism: Organism2D) -> void:
	stop_random_movement()
	_is_moving_to_organism = true
	_target_organism = organism


func move_to_random_point() -> void:
	var random_point := Vector2(
		randf_range(params.world_left_border, params.world_right_border),
		randf_range(params.world_upper_border, params.world_lower_border)
	)
	move_to_point(random_point)


func start_random_movement() -> void:
	connect("moved_to_point", move_to_random_point)
	move_to_random_point()


func stop_random_movement() -> void:
	_is_moving = false
	velocity = Vector2.ZERO
	disconnect("moved_to_point", move_to_random_point)


func _move(delta: float) -> void:
	if _is_moving_to_organism:
		move_to_point(_target_organism.global_position)
		var dist: float = global_position.distance_to(_target_organism.global_position)
		if dist <= params.move_to_organism_distance:
			_is_moving_to_organism = false
			moved_to_organism.emit(_target_organism)
			start_random_movement()

	if not _is_moving:
		return

	var diff : Vector2 = _target_point - global_position
	var direction: Vector2 = diff.normalized()
	velocity = speed * direction

	if (velocity * delta).length() > diff.length():
		velocity = Vector2.ZERO
		global_position = _target_point
		_is_moving = false
		moved_to_point.emit()
