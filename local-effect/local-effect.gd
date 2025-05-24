class_name LocalEffect extends Node2D
## Применяет эффект на [Organism] в пределах своей зоны действия.

## Эффект.
@export var summand: String
## Переменные эффекта.
@export var variables: PackedStringArray
## Цвет эффекта.
@export var color := Color("ffffff64")
## Длительность эффекта.
@export var duration: float = 15.0

var organisms: Dictionary[Organism, Variant] = {} # Set

@onready var sprite := $Sprite2D as Sprite2D
@onready var progress_bar := $ProgressBar as ProgressBar
@onready var detector := $OrganismDetector as OrganismDetector


func _ready() -> void:
	sprite.modulate = color
	progress_bar.max_value = duration
	progress_bar.value = duration
	detector.organism_entered.connect(_on_organism_detector_organism_entered)
	detector.organism_exited.connect(_on_organism_detector_organism_exited)


func _physics_process(delta: float) -> void:
	progress_bar.value -= delta
	if progress_bar.value > 0.0:
		return

	detector.organism_entered.disconnect(_on_organism_detector_organism_entered)
	detector.organism_exited.disconnect(_on_organism_detector_organism_exited)
	for organism: Organism in organisms.keys():
		organism.fitness_function.remove_summand(summand, variables)
	organisms.clear()

	queue_free()


func _on_organism_detector_organism_entered(organism: Organism) -> void:
	organism.fitness_function.add_summand(summand, variables)
	organisms.set(organism, null)


func _on_organism_detector_organism_exited(organism: Organism) -> void:
	organism.fitness_function.remove_summand(summand, variables)
	organisms.erase(organism)
