extends Node

var food: PackedScene = preload("res://food.tscn")


func _on_timer_timeout() -> void:
	var spawn_pos: Vector2 = Utils.get_world_random_point()
	var food_inst: Node2D = food.instantiate()
	food_inst.position = spawn_pos
	add_child(food_inst)
