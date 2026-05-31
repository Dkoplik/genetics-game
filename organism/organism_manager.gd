@tool
extends Node

const GA = preload("res://genetic/genetic_functions.gd")
const ORGANISM_SCENE: PackedScene = preload("res://organism/organism.tscn")

@export var params_ranges: GeneRanges:
	set(value):
		params_ranges = value
		if Engine.is_editor_hint():
			update_configuration_warnings()
		elif params_ranges == null:
			Log.err("Отсутствует ресурс с границами для генов")

@onready var organism_container: Node = $Organisms


func _on_crossover_timer_timeout() -> void:
	#var organisms: Array = organism_container.get_children()
	#var organism1: Organism = organisms.pick_random()
	#var organism2: Organism = organisms.pick_random()
	#Log.debug("Crossover between", organism1.name, "and", organism2.name)
	#
	#var new_size: float = ga.alpha_recombinationf(organism1.size, organism2.size)
	#var new_organism: Organism = organism_scene.instantiate()
	#new_organism.size = new_size
	#organism_container.add_child(new_organism)
	pass


func _on_mutation_timer_timeout() -> void:
	#var organisms: Array = organism_container.get_children()
	#var organism: Organism = organisms.pick_random()
	#Log.debug("Mutation of", organism.name)
	#organism.size = ga.real_value_mutation(organism.size, 1.5, 10)
	pass


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if params_ranges == null:
		var _err := warnings.append("Отсутствует ресурс с границами для генов")
	return warnings
