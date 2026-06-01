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

	var organism_pos: Vector2 = organism_blackboard.visible_organism.global_position
	var direction: Vector2 = organism_pos - character_body.global_position
	var target: Vector2 = -3.0 * direction
	character_body.move_to_point(
		target,
		organs_manager.get_total_speed(),
		organs_manager.get_total_rotation_speed(),
	)
	return SUCCESS


func get_closest_organism(organisms: Dictionary[ORGANISM_PHYSICS, int]) -> Vector2:
	var body_global_position: Vector2 = character_body.global_position
	var closest_organism_pos: Vector2 = Vector2.ZERO
	var dist_to_closest: float
	for organism_body: ORGANISM_PHYSICS in organisms:
		if organism_body == null or organism_body.is_queued_for_deletion():
			continue

		var organism_pos: Vector2 = organism_body.global_position
		if closest_organism_pos == Vector2.ZERO:
			closest_organism_pos = organism_pos
			dist_to_closest = body_global_position.distance_to(closest_organism_pos)
			continue

		var dist_to_food: float = body_global_position.distance_to(organism_pos)
		if dist_to_food < dist_to_closest:
			closest_organism_pos = organism_pos
			dist_to_closest = body_global_position.distance_to(closest_organism_pos)

	return closest_organism_pos
