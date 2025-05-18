class_name Population extends Node

func get_organisms() -> Array[Organism]:
	return get_children().filter(func(node: Node): return node is Organism)
