class_name InfoPanel extends Control

func update_info(organism: Organism) -> void:
	$VBoxContainer/HP.text = "HP: " + str(organism._hp)
	$VBoxContainer/TimeAlive.text = "Time alive: " + str(organism.get_time_alive())
	$VBoxContainer/Genome.text = "Genome: " + str(organism.genome.get_param_dict())
	$VBoxContainer/Mutations.text = "Mutations: " + str(organism.get_mutations_count())
	$VBoxContainer/Children.text = "Children: " + str(organism.get_children_count())
	$VBoxContainer/FitnessFunction.text = "Fitness function: " + organism.fitness_function.get_string_function()
