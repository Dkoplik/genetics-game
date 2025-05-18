class_name Population extends Node

var _organism_scene: PackedScene = preload("res://organism/organism.tscn")
var mutate_functions: Array[Callable]
var partner_choosers: Array[Callable]
var default_fitness_function := FitnessFunction.new()


func get_organisms() -> Array[Organism]:
	return get_children().filter(func(node: Node): return node is Organism)


func create_organism(genome: Genome) -> void:
	var organism: Organism = _organism_scene.instantiate()
	organism.genome = genome
	organism.mutate_function = mutate_functions.pick_random()
	organism.partner_chooser = partner_choosers.pick_random()
	organism.fitness_function = default_fitness_function
	add_child(organism)
