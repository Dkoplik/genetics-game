extends Node
## Простой спавнер еды.

const FOOD_SCENE: PackedScene = preload("res://food/food.tscn")


func _on_timer_timeout() -> void:
	var spawn_pos: Vector2 = Utils.get_world_random_point()
	var food_inst: Node2D = FOOD_SCENE.instantiate()
	food_inst.position = spawn_pos
	add_child(food_inst)
