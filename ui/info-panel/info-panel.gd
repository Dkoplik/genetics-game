class_name InfoPanel extends Control

var target_organism: Organism = null

@onready var hp_label: InfoLabel = $VBoxContainer/HP
@onready var target_label: InfoLabel = $VBoxContainer/Target
@onready var genome_label: InfoLabel = $VBoxContainer/Genome
@onready var ff_label: InfoLabel = $VBoxContainer/FitnessFunction
@onready var alive_label: InfoLabel = $VBoxContainer/TimeAlive
@onready var mutations_label: InfoLabel = $VBoxContainer/Mutations
@onready var children_label: InfoLabel = $VBoxContainer/Children


func _physics_process(_delta: float) -> void:
	if target_organism:
		_update_info(target_organism)


func _update_info(organism: Organism) -> void:
	hp_label.data = str(organism.get_hp())
	target_label.data = str(organism.behaviour.get_current_target())
	genome_label.data =str(organism.genome.get_param_dict())
	ff_label.data = organism.fitness_function.get_string_function()
	alive_label.data =str(organism.get_time_alive())
	mutations_label.data =str(organism.get_mutations_count())
	children_label.data =str(organism.get_children_count())
