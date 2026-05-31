extends Node2D
## Простая еда для организмов.
##
## Если организм касается этой еды, он получает энергию.

const ORGANISM = preload("res://organism/organism_root.gd")
const ORGANISM_BODY = preload("res://organism/body.gd")

@export var energy: float = 5.0


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not CharacterBody2D:
		return

	if body is not ORGANISM_BODY:
		return

	var organism_body: ORGANISM_BODY = body
	if organism_body.get_parent() is not ORGANISM:
		Log.err("Обнаружено тело организма, но его родитель не корень организма")
		return

	var organism: ORGANISM = body.get_parent()
	organism.energy += energy
	queue_free()
