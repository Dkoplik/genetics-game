class_name Organism
extends CharacterBody2D

@export var size: float = 1.0:
	set = set_size
var speed: float = 100.0
var energy: float = 4.0
var energy_consumption: float = 0.2 # per second

var _visible_food: Dictionary[Area2D, bool] = { } # set
var _target_point: Vector2


func _ready() -> void:
	set_size(size) # костыль
	_target_point = Utils.get_world_random_point()


func _process(delta: float) -> void:
	# energy
	energy -= delta * energy_consumption
	if energy < 0.0:
		queue_free()

	# movement
	var vec_to_target: Vector2 = _target_point - position
	if vec_to_target.length() < 1.0:
		if _visible_food.is_empty():
			_target_point = Utils.get_world_random_point()
		else:
			_target_point = get_closest_food(_visible_food).global_position

	var direction_to_target: Vector2 = position.direction_to(_target_point)
	velocity = speed * direction_to_target
	var _collided: bool = move_and_slide()


func set_size(new_size: float) -> void:
	size = clampf(new_size, 1.0 / 4.0, 2.0)
	scale = Vector2(size, size)
	speed = clampf(100 * (2 - size), 0.0, 1000.0)
	energy_consumption = 0.2 * size * size


func get_closest_food(foods: Dictionary[Area2D, bool]) -> Area2D:
	var closest_food: Area2D = null
	var dist_to_closest: float
	for food: Area2D in foods:
		if closest_food == null:
			closest_food = food
			dist_to_closest = global_position.distance_to(closest_food.global_position)
			continue

		var dist_to_food: float = global_position.distance_to(food.global_position)
		if dist_to_food < dist_to_closest:
			closest_food = food
			dist_to_closest = global_position.distance_to(closest_food.global_position)

	return closest_food


func _on_vision_area_entered(area: Area2D) -> void:
	_visible_food[area] = true
	_target_point = get_closest_food(_visible_food).global_position


func _on_vision_area_exited(area: Area2D) -> void:
	var deleted: bool = _visible_food.erase(area)
	if not deleted:
		pass
	if not _visible_food.is_empty():
		_target_point = get_closest_food(_visible_food).global_position
