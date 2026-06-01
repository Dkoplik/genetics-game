class_name OrganismBlackboard
extends Blackboard

const ORGANISM_PHYSICS := preload("res://organism/character_body_2d.gd")
const ORGANISM_CLASS := preload("res://organism/organism_root.gd")
const FOOD_CLASS := preload("res://food/food.gd")

var visible_food: Dictionary[Vector2, int] = { } # set
var visible_organism: ORGANISM_PHYSICS = null


func _physics_process(_delta: float) -> void:
	var cur_time: int = Time.get_ticks_msec()
	var for_deletion: Array[Vector2] = []
	for key: Vector2 in visible_food:
		var sec_passed: float = float(cur_time - visible_food[key]) / 1000.0
		sec_passed = max(0.0, sec_passed)
		if sec_passed >= 0.4:
			for_deletion.append(key)

	for key: Vector2 in for_deletion:
		var _err := visible_food.erase(key)


func _on_vision_area_entered(area: Area2D) -> void:
	if area.get_parent() is not FOOD_CLASS:
		return

	var parent: Node2D = area.get_parent()
	visible_food[parent.global_position] = Time.get_ticks_msec() + 1_000


func _on_vision_area_exited(area: Area2D) -> void:
	if area.get_parent() is not FOOD_CLASS:
		return

	var parent: Node2D = area.get_parent()
	visible_food[parent.global_position] = Time.get_ticks_msec() # начать отсчёт


func _on_vision_body_entered(body: Node2D) -> void:
	if body is not ORGANISM_PHYSICS:
		return

	var organism_body: ORGANISM_PHYSICS = body
	var my_organism: ORGANISM_CLASS = get_parent()
	if is_same(organism_body, my_organism.character_body):
		return

	visible_organism = organism_body


func _on_vision_body_exited(body: Node2D) -> void:
	if body is not ORGANISM_PHYSICS:
		return

	var organism_body: ORGANISM_PHYSICS = body
	var my_organism: ORGANISM_CLASS = get_parent()
	if is_same(organism_body, my_organism.character_body):
		return

	visible_organism = null
