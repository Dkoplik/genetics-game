extends Node2D

@export var energy: float = 5.0


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not CharacterBody2D:
		Log.error("Food collided, but it is not CharacterBody2D:", body)
		return

	var organism: CharacterBody2D = body
	if not organism.name.begins_with("Organism"):
		Log.warn("Имя CharacterBody2D не начинается на Organism:", organism.name, "| это точно организм? :", organism)

	# TODO organism += energy
	queue_free()
