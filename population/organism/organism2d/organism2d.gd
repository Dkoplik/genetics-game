class_name Organism2D extends CharacterBody2D
## Отвечает за поведение и положение организма в 2D пространстве.

signal canceled_moving_to_organism(target: Organism2D)
signal canceled_moving_to_point(point: Vector2)
signal moved_to_organism2d(target: Organism2D)
signal moved_to_point(point: Vector2)

## Основные параметры.
var params: Organism2DParams = preload("./organism2d-default-params.tres")

var _is_moving_to_organism := false
var _target_organism: Organism2D

var _is_moving_to_point := false
var _target_point: Vector2

var _is_randomly_moving := false

## Форма организма (коллизия).
var _shape: CircleShape2D


func _ready() -> void:
	_shape = ($CollisionShape2D as CollisionShape2D).shape as CircleShape2D
	start_random_movement()


func _physics_process(delta: float) -> void:
	_moving_to_organism()
	_moving_to_point(delta)
	move_and_slide()


## Начать движение к случайным точкам.
func start_random_movement() -> void:
	if _is_randomly_moving:
		push_warning("Организм уже движется в случайных направлениях")
		return
	_is_randomly_moving = true
	_move_to_random_point()
	moved_to_point.connect(_move_to_random_point)


## Прекратить движение к случайным точкам.
func stop_random_movement() -> void:
	if not _is_randomly_moving:
		push_warning("Случайное движение уже остановлено")
		return
	_is_randomly_moving = false
	if _is_moving_to_point:
		canceled_moving_to_point.emit(_target_point)
	_is_moving_to_point = false
	moved_to_point.disconnect(_move_to_random_point)


## Начать движение к организму [param organism]. Если до этого осуществлял
## движение до другой цели, то испускает соответствующий сигнал об отмене
## и меняет цель.
func move_to_organism2d(organism: Organism2D) -> void:
	if _is_randomly_moving:
		stop_random_movement()
	if _is_moving_to_organism: # До этого двигался к другому организму
		canceled_moving_to_organism.emit(_target_organism)
	_is_moving_to_organism = true
	_target_organism = organism


## Начать движение к точке [param point]. Если до этого осуществлял движение до
## другой цели, то испускает соответствующий сигнал об отмене и меняет цель.
## Если [param save_target_organism] = true, то не сбрасывает целевой организм.
func move_to_point(point: Vector2, save_target_organism := false) -> void:
	if _is_randomly_moving:
		stop_random_movement()
	# До этого двигался к другому организму
	if _is_moving_to_organism and not save_target_organism:
		canceled_moving_to_organism.emit(_target_organism)
	if _is_moving_to_point: # До этого двигался к другой точке
		canceled_moving_to_point.emit(_target_point)
	_is_moving_to_organism = false
	_is_moving_to_point = true
	_target_point = point


## Случайная точка в пределах границ мира, указанных в [member params].
func get_random_point() -> Vector2:
	return Vector2(
		randf_range(params.world_left_border, params.world_right_border),
		randf_range(params.world_upper_border, params.world_lower_border)
	)


## Обработать движение до организма. Завязано на движении к точке, поэтому
## должно вызываться до [member _moving_to_point].
func _moving_to_organism() -> void:
	if not _is_moving_to_organism:
		return

	move_to_point(_target_organism.global_position, true)
	var dist: float = global_position.distance_to(_target_organism.global_position)
	if dist <= params.move_to_organism_dist_coef * _shape.radius:
		_is_moving_to_organism = false
		moved_to_organism2d.emit(_target_organism)


## Обработать движение до точки.
func _moving_to_point(delta: float) -> void:
	if not _is_moving_to_point:
		return

	var diff : Vector2 = _target_point - global_position
	var direction: Vector2 = diff.normalized()
	velocity = params.speed * direction
	if (velocity * delta).length() > diff.length():
		velocity = Vector2.ZERO
		global_position = _target_point
		moved_to_point.emit(_target_point)


## Назначить движение к случайной точке.
func _move_to_random_point() -> void:
	_target_point = get_random_point()
	_is_moving_to_point = true
