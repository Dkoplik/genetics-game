class_name InfoPanel extends Control

var target_organism: Organism = null

@onready var hp_label: InfoLabel = $VBoxContainer/HBoxContainer/VBoxContainer/HP
@onready var genome_label: InfoLabel = $VBoxContainer/HBoxContainer/VBoxContainer_2/Genome
@onready var ff_label: InfoLabel = $VBoxContainer/FitnessFunction
@onready var alive_label: InfoLabel = $VBoxContainer/HBoxContainer/VBoxContainer/TimeAlive
@onready var mutations_label: InfoLabel = $VBoxContainer/HBoxContainer/VBoxContainer/Mutations
@onready var children_label: InfoLabel = $VBoxContainer/HBoxContainer/VBoxContainer/Children


func _physics_process(_delta: float) -> void:
	if target_organism:
		_update_info(target_organism)


func _update_info(organism: Organism) -> void:
	hp_label.data = "%0.2f" % organism.get_hp()
	genome_label.data =_format_dict(organism.genome.get_param_dict())
	ff_label.data = organism.fitness_function.get_string_function()
	alive_label.data = "%d" % organism.get_time_alive() + " sec"
	mutations_label.data =str(organism.get_mutations_count())
	children_label.data =str(organism.get_children_count())


func _format_dict(dict: Dictionary) -> String:
	var res := "{\n"
	for key: Variant in dict.keys():
		res += str(key) + ": " + str(dict.get(key)) + "\n"
	res += "}"
	return res
