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

	character_body.move_to_point(
		organism_blackboard.visible_organism.global_position,
		organs_manager.get_total_speed(),
		organs_manager.get_total_rotation_speed(),
	)
	return SUCCESS
