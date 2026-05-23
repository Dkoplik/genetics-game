class_name Organism
extends Node

@export var energy: float = 15.0
var _visible_food: Dictionary[Area2D, bool] = { } # set

@onready var _target_point: Vector2 = Utils.get_world_random_point()
@onready var _body: OrganismBody = $Body


func _process(delta: float) -> void:
	# energy
	energy -= _body.get_total_consumption() * delta
	if energy < 0.0:
		queue_free()

	# movement
	var vec_to_target: Vector2 = _target_point - _body.position
	if vec_to_target.length() < 1.0:
		if _visible_food.is_empty():
			_target_point = Utils.get_world_random_point()
		else:
			_target_point = get_closest_food(_visible_food).global_position

	var direction_to_target: Vector2 = _body.position.direction_to(_target_point)
	_body.velocity = _body.speed * direction_to_target
	var _collided: bool = _body.move_and_slide()


func get_closest_food(foods: Dictionary[Area2D, bool]) -> Area2D:
	var closest_food: Area2D = null
	var dist_to_closest: float
	for food: Area2D in foods:
		if closest_food == null:
			closest_food = food
			dist_to_closest = _body.global_position.distance_to(closest_food.global_position)
			continue

		var dist_to_food: float = _body.global_position.distance_to(food.global_position)
		if dist_to_food < dist_to_closest:
			closest_food = food
			dist_to_closest = _body.global_position.distance_to(closest_food.global_position)

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
