@tool
extends ActionLeaf

const ORGANISM_PHYSICS := preload("res://organism/character_body_2d.gd")

@onready var _target_point: Vector2 = Utils.get_world_random_point()


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor is not ORGANISM_PHYSICS:
		return FAILURE

	var character_body: ORGANISM_PHYSICS = actor
	var vec_to_target: Vector2 = _target_point - character_body.position
	if vec_to_target.length() < 1.0:
		_target_point = Utils.get_world_random_point()

	var direction_to_target: Vector2 = character_body.position.direction_to(_target_point)
	character_body.velocity = character_body.speed * direction_to_target
	return SUCCESS
