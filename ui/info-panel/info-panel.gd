class_name InfoPanel extends Control

var target_organism: Organism = null

@onready var hp_label: InfoLabel = $HBoxContainer/VBoxContainer/HP
@onready var genome_label: InfoLabel = $HBoxContainer/VBoxContainer_2/Genome
@onready var ff_label: InfoLabel = $HBoxContainer_2/FitnessFunction
@onready var f_label: InfoLabel = $HBoxContainer/VBoxContainer/Fitness
@onready var alive_label: InfoLabel = $HBoxContainer/VBoxContainer/TimeAlive
@onready var mutations_label: InfoLabel = $HBoxContainer/VBoxContainer/Mutations
@onready var children_label: InfoLabel = $HBoxContainer/VBoxContainer/Children


func _physics_process(_delta: float) -> void:
	if target_organism:
		_update_info(target_organism)


func clear() -> void:
	target_organism = null
	hp_label.data = ""
	genome_label.data = ""
	ff_label.data = ""
	alive_label.data = ""
	mutations_label.data = ""
	children_label.data = ""


func _update_info(organism: Organism) -> void:
	hp_label.data = "%0.2f" % organism.get_hp()
	genome_label.data = _format_dict(organism.genome.get_param_dict())
	ff_label.data = organism.fitness_function.get_string_function()
	f_label.data = "%0.3f" % organism.get_fitness()
	alive_label.data = "%d" % organism.get_time_alive() + " sec"
	mutations_label.data = str(organism.get_mutations_count())
	children_label.data = str(organism.get_children_count())


func _format_dict(dict: Dictionary) -> String:
	var res := "{\n"
	for key: Variant in dict.keys():
		res += str(key) + ": " + str(dict.get(key)) + "\n"
	res += "}"
	return res
