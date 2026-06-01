@tool
extends ActionLeaf

const ORGANISM_CLASS := preload("res://organism/organism_root.gd")
const ORGANISM_PHYSICS := preload("res://organism/character_body_2d.gd")
const ORGANS_MANAGER := preload("res://organism/organs_manager.gd")
const ORGANISM_BLACKBOARD := preload("res://organism/beehave_tree/blackboard.gd")

var organism: ORGANISM_CLASS = null
var character_body: ORGANISM_PHYSICS = null
var organs_manager: ORGANS_MANAGER = null
var organism_blackboard: ORGANISM_BLACKBOARD = null


func before_run(actor: Node, blackboard: Blackboard) -> void:
	organism = actor
	character_body = organism.character_body
	organs_manager = organism.organs_manager
	organism_blackboard = blackboard


func tick(_actor: Node, _blackboard: Blackboard) -> int:
	if organism == null \
			or character_body == null \
			or organs_manager == null \
			or organism_blackboard == null:
		return FAILURE

	var food_pos: Vector2 = get_closest_food(organism_blackboard.visible_food)
	character_body.move_to_point(
		food_pos,
		organs_manager.get_total_speed(),
		organs_manager.get_total_rotation_speed(),
	)
	return SUCCESS


func get_closest_food(foods: Dictionary[Vector2, int]) -> Vector2:
	var body_global_position: Vector2 = character_body.global_position
	var closest_food_pos: Vector2 = Vector2.ZERO
	var dist_to_closest: float
	for food_pos: Vector2 in foods:
		if closest_food_pos == Vector2.ZERO:
			closest_food_pos = food_pos
			dist_to_closest = body_global_position.distance_to(closest_food_pos)
			continue

		var dist_to_food: float = body_global_position.distance_to(food_pos)
		if dist_to_food < dist_to_closest:
			closest_food_pos = food_pos
			dist_to_closest = body_global_position.distance_to(closest_food_pos)

	return closest_food_pos
