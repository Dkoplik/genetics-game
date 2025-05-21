class_name InfoPanel extends Control

func update_info(organism: Organism) -> void:
	$VBoxContainer/HP.text = "HP: " + str(organism._hp)
	$VBoxContainer/TimeAlive.text = "Time alive: " #TODO
	$VBoxContainer/Genome.text = "Genome: " + str(organism.genome.get_param_dict())
	$VBoxContainer/Mutations.text = "Mutations: " #TODO
	$VBoxContainer/Children.text = "Children: " #TODO
	$VBoxContainer/FitnessFunction.text = "Fitness function: " #TODO
