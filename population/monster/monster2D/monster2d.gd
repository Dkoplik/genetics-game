class_name Monster2D extends CharacterBody2D
## Отвечает за поведение и положение монстра в 2D пространстве.

signal canceled_moving_to_organism(target: Organism2D)
signal moved_to_organism2d(target: Organism2D)
signal lost_target

enum STATE { IDLE, MOVING_TO_ORGANISM }

## Основные параметры.
var params: Monster2DParams = preload("res://config/monster2d-params.tres")

var _cur_state: STATE = STATE.IDLE
var _target_organism: Organism2D = null
var _target_point: Vector2

## Форма монстра (коллизия).
var _shape: CircleShape2D


func _ready() -> void:
	_shape = ($CollisionShape2D as CollisionShape2D).shape as CircleShape2D


func _physics_process(delta: float) -> void:
	_moving_to_organism()
	_moving_to_point(delta)
	move_and_slide()


## Начать движение к организму [param organism]. Если до этого осуществлял
## движение до другой цели, то испускает соответствующий сигнал об отмене
## и меняет цель.
func move_to_organism2d(organism: Organism2D) -> void:
	_change_state(STATE.MOVING_TO_ORGANISM)
	_target_organism = organism


func get_current_target() -> Organism2D:
	match _cur_state:
		STATE.MOVING_TO_ORGANISM:
			return _target_organism
	return null


## Обработать движение до организма. Завязано на движении к точке, поэтому
## должно вызываться до [member _moving_to_point].
func _moving_to_organism() -> void:
	if _cur_state != STATE.MOVING_TO_ORGANISM:
		return

	# Цели больше не существует.
	if not _target_organism:
		_target_organism = null
		_change_state(STATE.IDLE)
		lost_target.emit()
		return

	_target_point = _target_organism.global_position
	
	var dist: float = global_position.distance_to(_target_point)
	var optimal_dist: float = params.move_to_organism_dist_coef * _shape.radius
	if dist <= optimal_dist:
		moved_to_organism2d.emit(_target_organism)


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


## Сменить текущее состояние и запустить необходимые сигналы.
func _change_state(new_state: STATE) -> void:
	if _cur_state == new_state:
		match _cur_state:
			STATE.MOVING_TO_ORGANISM:
				canceled_moving_to_organism.emit(_target_organism)
			STATE.IDLE:
				push_warning("Organism is already idle")
	_cur_state = new_state
