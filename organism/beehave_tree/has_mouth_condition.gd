@tool
extends ConditionLeaf

const ORGANISM_CLASS := preload("res://organism/organism_root.gd")
const ORGANS_MANAGER := preload("res://organism/organs_manager.gd")

var organism: ORGANISM_CLASS = null
var organs_manager: ORGANS_MANAGER = null


func before_run(actor: Node, _blackboard: Blackboard) -> void:
	organism = actor
	organs_manager = organism.organs_manager


func tick(_actor: Node, _blackboard: Blackboard) -> int:
	if organs_manager.has_mouth():
		return SUCCESS
	return FAILURE
