class_name OrganismBlackboard
extends Blackboard

var visible_food: Dictionary[Vector2, int] = { } # set


func _physics_process(_delta: float) -> void:
	var cur_time: int = Time.get_ticks_msec()
	for key: Vector2 in visible_food:
		if visible_food[key] < 0: # отсчёт не начат
			continue

		var sec_passed: float = float(cur_time - visible_food[key]) / 1000.0
		if sec_passed >= 0.28:
			var _err := visible_food.erase(key)


func _on_vision_area_entered(area: Area2D) -> void:
	var parent: Node2D = area.get_parent()
	visible_food[parent.global_position] = -1 # нет отсчёта


func _on_vision_area_exited(area: Area2D) -> void:
	var parent: Node2D = area.get_parent()
	visible_food[parent.global_position] = Time.get_ticks_msec() # начать отсчёт
