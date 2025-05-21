extends Node

@onready var population: Population = $Population


func _ready() -> void:
	var p_params := PopulationParams.new()
	p_params.mutate_functions = [GACallables.random_binary_mutation]
	p_params.partner_choosers = [GACallables.random_partner]
	p_params.crossover_functions = [GACallables.discrete_recombination]
	p_params.genome_param_types = {"Ice": TYPE_FLOAT, "Fire": TYPE_FLOAT}
	population.params = p_params
	for i in range(4):
		population.create_random_organism()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var effect := preload("res://local-effect/local-effect.tscn").instantiate()
			effect.summand = "max(100 - sqrt(Fire), 0)"
			effect.variables = ["Fire"]
			effect.position = event.position
			add_child(effect)
