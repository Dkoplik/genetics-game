class_name GACallables extends Object

## Панмиксия
static func random_partner(organisms: Array[Organism]) -> Organism:
	return organisms.pick_random()


static func discrete_recombination(parent1: Genome, parent2: Genome) -> Genome:
	var param_names: PackedStringArray = parent1.get_param_dict().keys()
	var new_params: Dictionary[String, Variant] = {}
	for param_name: String in param_names:
		var parent_of_param: Genome =  [parent1, parent2].pick_random()
		new_params.set(param_name, parent_of_param.get_param(param_name))
	return Genome.new(new_params)


static func random_binary_mutation(genome: Genome) -> void:
	var bit_index = randi_range(0, genome.bit_array_size())
	var bit = 0 if genome.get_bit(bit_index) else 1
	genome.set_bit(bit_index, bit)
