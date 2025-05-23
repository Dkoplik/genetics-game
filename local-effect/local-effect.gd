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

@onready var sprite := $Sprite2D as Sprite2D
@onready var progress_bar := $ProgressBar as ProgressBar


func _ready() -> void:
	sprite.modulate = color
	progress_bar.max_value = duration
	progress_bar.value = duration


func _physics_process(delta: float) -> void:
	progress_bar.value -= delta
	if progress_bar.value <= 0.0:
		queue_free()


func _on_organism_detector_organism_entered(organism: Organism) -> void:
	organism.fitness_function.add_summand(summand, variables)


func _on_organism_detector_organism_exited(organism: Organism) -> void:
	organism.fitness_function.remove_summand(summand, variables)
