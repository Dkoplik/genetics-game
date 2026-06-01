@tool
extends Node

const RNG := preload("res://etc/random.gd")
const GA := preload("res://genetic/genetic_functions.gd")
const ORGANISM_SCENE: PackedScene = preload("res://organism/organism.tscn")
const ORGANISM_CLASS := preload("res://organism/organism_root.gd")

@export var gene_ranges: GeneRanges:
	set(value):
		gene_ranges = value
		if Engine.is_editor_hint():
			update_configuration_warnings()
		elif gene_ranges == null:
			Log.err("Отсутствует ресурс с границами для генов")

@export var singular_types: Array[StringName] = []
@export var exclude_types: Array[StringName] = []
@export var probability_curve: Curve
@export var add_gene_probability: float = 0.4:
	set(value):
		add_gene_probability = clampf(value, 0.0, 1.0)
@export var mutate_gene_probability: float = 0.8:
	set(value):
		mutate_gene_probability = clampf(value, 0.0, 1.0)

@onready var organism_container: Node = $Organisms


func _on_crossover_timer_timeout() -> void:
	var organisms: Array = organism_container.get_children()
	if organisms.size() < 2:
		return

	var organism1: ORGANISM_CLASS = organisms.pick_random()
	var organism2: ORGANISM_CLASS = organisms.pick_random()
	Log.debug("Скрещивание между", organism1.name, "и", organism2.name)

	var genome1: Array[Gene] = organism1.genome
	var genome2: Array[Gene] = organism1.genome

	Log.debug("Геном 1-ого родителя:", genome1)
	Log.debug("Геном 2-ого родителя:", genome2)

	var new_genome: Array[Gene] = GA.mix_genes(
		genome1,
		genome2,
		singular_types,
		exclude_types,
		probability_curve,
	)
	Log.debug("Новый геном:", new_genome)

	var new_organism: ORGANISM_CLASS = ORGANISM_SCENE.instantiate()
	organism_container.add_child(new_organism, true)
	new_organism.genome = new_genome


func _on_mutation_timer_timeout() -> void:
	var organisms: Array = organism_container.get_children()
	var organism: ORGANISM_CLASS = organisms.pick_random()
	Log.debug("Мутация организма", organism.name)

	if RNG.roll_dice(add_gene_probability):
		Log.debug("Добавление случайного гена")
		Log.debug("Геном до добавления:", organism.genome)
		GA.add_random_gene(organism.genome, gene_ranges, exclude_types)
		Log.debug("Геном после добавления:", organism.genome)

	if RNG.roll_dice(mutate_gene_probability):
		Log.debug("Мутация случайного гена")
		Log.debug("Геном до мутации:", organism.genome)
		GA.mutate_random_gene(organism.genome, gene_ranges)
		Log.debug("Геном после мутации:", organism.genome)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if gene_ranges == null:
		var _err := warnings.append("Отсутствует ресурс с границами для генов")
	return warnings
