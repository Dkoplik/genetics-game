extends Node

@export var start_population_size: int = 4

@onready var population := $Population as Population

var p_params := PopulationParams.new()
#var org_params := OrganismParams.new()
#var org2d_params := Organism2DParams.new()


func _ready() -> void:
	# Population Params
	p_params.mutate_functions = [GACallables.random_binary_mutation]
	p_params.partner_choosers = [GACallables.random_partner]
	p_params.crossover_functions = [GACallables.discrete_recombination]
	p_params.genome_param_types = {"Ice": TYPE_FLOAT, "Fire": TYPE_FLOAT, "Radiation": TYPE_FLOAT}
	population.params = p_params

	# Start Population
	for i in range(start_population_size):
		population.create_random_organism()


# Костыль для спавна эффектов.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var effect := preload("res://local-effect/local-effect.tscn").instantiate()
			effect.summand = "max(100 - sqrt(Fire), 0)"
			effect.variables = ["Fire"]
			effect.position = event.position
			add_child(effect)
