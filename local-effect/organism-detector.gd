class_name OrganismDetector extends Area2D

signal organism_entered(organism: Organism)
signal organism_exited(organism: Organism)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is not Organism2D:
		return
	if body.get_parent() is not Organism:
		push_error("У Organism2D родитель не Organism")
		return
	organism_entered.emit(body.get_parent())


func _on_body_exited(body: Node2D) -> void:
	if body is not Organism2D:
		return
	if body.get_parent() is not Organism:
		push_error("У Organism2D родитель не Organism")
		return
	organism_exited.emit(body.get_parent())
