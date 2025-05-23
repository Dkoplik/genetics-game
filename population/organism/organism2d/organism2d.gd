class_name Organism2D extends CharacterBody2D
## Отвечает за поведение и положение организма в 2D пространстве.

signal canceled_moving_to_organism(target: Organism2D)
signal canceled_moving_to_point(point: Vector2)
signal moved_to_organism2d(target: Organism2D)
signal moved_to_point(point: Vector2)

enum STATE {IDLE, MOVING_TO_POINT, MOVING_TO_ORGANISM, WANDERING}

## Основные параметры.
var params: Organism2DParams = preload("./organism2d-default-params.tres")

var _cur_state: STATE = STATE.IDLE
var _target_organism: Organism2D = null
var _target_point: Vector2

## Форма организма (коллизия).
var _shape: CircleShape2D

@onready var _sprite := $OrganismSprite as OrganismSprite


func _ready() -> void:
	_shape = ($CollisionShape2D as CollisionShape2D).shape as CircleShape2D
	start_wandering()


func _physics_process(delta: float) -> void:
	_random_movement_pause()
	_moving_to_organism()
	_moving_to_point(delta)
	move_and_slide()
	_sprite.update_data((get_parent() as Organism).genome)


## Начать движение к случайным точкам.
func start_wandering() -> void:
	_change_state(STATE.WANDERING)
	_move_to_random_point()
	moved_to_point.connect(_move_to_random_point)


## Прекратить движение к случайным точкам.
func stop_wandering() -> void:
	if _cur_state != STATE.WANDERING:
		push_warning("Случайное движение уже остановлено")
		return
	moved_to_point.disconnect(_move_to_random_point)
	_cur_state = STATE.IDLE


## Начать движение к организму [param organism]. Если до этого осуществлял
## движение до другой цели, то испускает соответствующий сигнал об отмене
## и меняет цель.
func move_to_organism2d(organism: Organism2D) -> void:
	_change_state(STATE.MOVING_TO_ORGANISM)
	_target_organism = organism


## Начать движение к точке [param point]. Если до этого осуществлял движение до
## другой цели, то испускает соответствующий сигнал об отмене и меняет цель.
func move_to_point(point: Vector2) -> void:
	_change_state(STATE.MOVING_TO_POINT)
	_target_point = point


func get_current_target() -> Variant:
	match _cur_state:
		STATE.MOVING_TO_ORGANISM:
			return _target_organism
		STATE.MOVING_TO_POINT:
			return _target_point
	return null


## Случайная точка в пределах границ мира, указанных в [member params].
func _get_random_point() -> Vector2:
	return Vector2(
		randf_range(params.world_left_border, params.world_right_border),
		randf_range(params.world_upper_border, params.world_lower_border)
	)


## Обработать движение до организма. Завязано на движении к точке, поэтому
## должно вызываться до [member _moving_to_point].
func _moving_to_organism() -> void:
	if _cur_state != STATE.MOVING_TO_ORGANISM:
		return

	# Цели больше не существует.
	if not _target_organism:
		_target_organism = null
		start_wandering()
		return

	_target_point = _target_organism.global_position
	var dist: float = global_position.distance_to(_target_point)
	if dist <= params.move_to_organism_dist_coef * _shape.radius:
		moved_to_organism2d.emit(_target_organism)
		_cur_state = STATE.IDLE # dont trigger cancelation of target
		start_wandering()


## Обработать движение до точки.
func _moving_to_point(delta: float) -> void:
	if _cur_state == STATE.IDLE:
		return

	var diff: Vector2 = _target_point - global_position
	var direction: Vector2 = diff.normalized()
	velocity = params.speed * direction
	if (velocity * delta).length() > diff.length():
		velocity = Vector2.ZERO
		global_position = _target_point
		if _cur_state == STATE.MOVING_TO_POINT or _cur_state == STATE.WANDERING:
			moved_to_point.emit(_target_point)


func _random_movement_pause() -> void:
	if _cur_state != STATE.WANDERING:
		return
	if not Numeric.roll_dice(params.pause_chance):
		return
	stop_wandering()
	var timer: SceneTreeTimer = get_tree().create_timer(params.pause_duration)
	timer.timeout.connect(_resume_wandering)


func _resume_wandering() -> void:
	if _cur_state != STATE.IDLE:
		return
	start_wandering()


## Назначить движение к случайной точке.
func _move_to_random_point(_previous_point := Vector2.ZERO) -> void:
	_target_point = _get_random_point()


## Change state with all signals, when needed.
func _change_state(new_state: STATE) -> void:
	match _cur_state:
		STATE.WANDERING:
			stop_wandering()
		STATE.MOVING_TO_ORGANISM:
			canceled_moving_to_organism.emit(_target_organism)
		STATE.MOVING_TO_POINT:
			canceled_moving_to_point.emit(_target_point)

	if _cur_state == new_state:
		match _cur_state:
			STATE.WANDERING:
				push_warning("Organism is already wandering")
			STATE.IDLE:
				push_warning("Organism is already idle")
	_cur_state = new_state
