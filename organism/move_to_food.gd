@tool
extends ActionLeaf

const ORGANISM_PHYSICS := preload("res://organism/character_body_2d.gd")

func tick(actor: Node, blackboard: Blackboard) -> int:
	var food: Area2D = get_closest_food(actor, blackboard.visible_food)
	if food == null:
		return FAILURE
	var target_point: Vector2 = food.global_position
	var vec_to_target: Vector2 = target_point - actor.position
	var direction_to_target: Vector2 = actor.position.direction_to(target_point)
	actor.velocity = actor.speed * direction_to_target
	return SUCCESS


func get_closest_food(actor: Node, foods: Dictionary[Area2D, bool]) -> Area2D:
	var closest_food: Area2D = null
	var dist_to_closest: float
	for food: Area2D in foods:
		if closest_food == null:
			closest_food = food
			dist_to_closest = actor.global_position.distance_to(closest_food.global_position)
			continue

		var dist_to_food: float = actor.global_position.distance_to(food.global_position)
		if dist_to_food < dist_to_closest:
			closest_food = food
			dist_to_closest = actor.global_position.distance_to(closest_food.global_position)

	return closest_food
