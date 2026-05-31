class_name OrganismBlackboard
extends Blackboard

var visible_food: Dictionary[Area2D, bool] = { } # set


func _on_vision_area_entered(area: Area2D) -> void:
	visible_food[area] = true


func _on_vision_area_exited(area: Area2D) -> void:
	var deleted: bool = visible_food.erase(area)
	if not deleted:
		Log.warn(
			"Попытка удалить еду",
			area.name,
			area,
			"из поля зрения, но она уже отсутствует",
		)
