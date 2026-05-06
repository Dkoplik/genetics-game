extends Node2D

@export var energy: float = 5.0


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not CharacterBody2D:
		Log.error("Food collided, but it is not CharacterBody2D:", body)
		return

	if body is not Organism:
		Log.warn("CharacterBody2D не является Organism, есть другой CharacterBody2D?", body)
	var organism: Organism = body

	organism.energy += energy
	queue_free()
