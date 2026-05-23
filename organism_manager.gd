extends Node

const ga = preload("res://etc/genetic_functions.gd")
const organism_scene: PackedScene = preload("res://organism/organism.tscn")
@onready var organism_container: Node = $Organisms

func _on_crossover_timer_timeout() -> void:
	var organisms: Array = organism_container.get_children()
	var organism1: Organism = organisms.pick_random()
	var organism2: Organism = organisms.pick_random()
	Log.debug("Crossover between", organism1.name, "and", organism2.name)

	var new_size: float = ga.alpha_recombinationf(organism1.size, organism2.size)
	var new_organism: Organism = organism_scene.instantiate()
	new_organism.size = new_size
	organism_container.add_child(new_organism)


func _on_mutation_timer_timeout() -> void:
	var organisms: Array = organism_container.get_children()
	var organism: Organism = organisms.pick_random()
	Log.debug("Mutation of", organism.name)
	organism.size = ga.real_value_mutation(organism.size, 1.5, 10)
