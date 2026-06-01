@tool
extends ActionLeaf

const ORGANISM_CLASS := preload("res://organism/organism_root.gd")
const ORGANISM_PHYSICS := preload("res://organism/character_body_2d.gd")
const ORGANS_MANAGER := preload("res://organism/organs_manager.gd")

var organism: ORGANISM_CLASS = null
var character_body: ORGANISM_PHYSICS = null
var organs_manager: ORGANS_MANAGER = null

@onready var target_point: Vector2 = Utils.get_world_random_point()


func before_run(actor: Node, _blackboard: Blackboard) -> void:
	organism = actor
	character_body = organism.character_body
	organs_manager = organism.organs_manager


func tick(_actor: Node, _blackboard: Blackboard) -> int:
	if organism == null or character_body == null or organs_manager == null:
		return FAILURE

	var vec_to_target: Vector2 = target_point - character_body.global_position
	if vec_to_target.length() < 5.0:
		target_point = Utils.get_world_random_point()

	character_body.move_to_point(
		target_point,
		organs_manager.get_total_speed(),
		organs_manager.get_total_rotation_speed(),
	)
	return SUCCESS


func interrupt(_actor: Node, _blackboard: Blackboard) -> void:
	target_point = Utils.get_world_random_point()
