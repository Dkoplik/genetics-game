extends Node2D
## Простая еда для организмов.
##
## Если организм касается этой еды, он получает энергию.

const ORGANISM = preload("res://organism/organism_root.gd")
const ORGANISM_PHYSICS = preload("res://organism/character_body_2d.gd")

@export var energy: float = 7.0
@export var deceleration: float = 70.0

var velocity: Vector2 = Vector2.ZERO


func _physics_process(delta: float) -> void:
	var target: Vector2 = global_position + velocity
	global_position = global_position.move_toward(target, velocity.length() * delta)
	velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)


func set_random_velocity() -> void:
	var speed: float = randf_range(90.0, 110.0)
	var random_vec: Vector2 = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	var direction: Vector2 = random_vec.normalized()
	velocity = direction * speed


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not CharacterBody2D:
		return

	if body is not ORGANISM_PHYSICS:
		return

	var organism_body: ORGANISM_PHYSICS = body
	if organism_body.get_parent() is not ORGANISM:
		Log.err("Обнаружено тело организма, но его родитель не корень организма")
		return

	var organism: ORGANISM = body.get_parent()
	organism.energy += energy
	if organism.blackboard.visible_food.has(global_position):
		var _err := organism.blackboard.visible_food.erase(global_position)
	queue_free()
