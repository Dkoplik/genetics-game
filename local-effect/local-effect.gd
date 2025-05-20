class_name LocalEffect extends Node2D

@export var summand: String
@export var variables: PackedStringArray


func _on_organism_detector_organism_entered(organism: Organism) -> void:
	organism.fitness_function.add_summand(summand, variables)


func _on_organism_detector_organism_exited(organism: Organism) -> void:
	organism.fitness_function.remove_summand(summand, variables)
