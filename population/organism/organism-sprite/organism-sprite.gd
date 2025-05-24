class_name OrganismSprite extends Node2D

@onready var fire := $Fire as Sprite2D
@onready var ice := $Ice as Sprite2D
@onready var radiation := $Radiation as Sprite2D

var genome_ref: Genome = null


func _ready() -> void:
	fire.modulate.a = 0.0
	ice.modulate.a = 0.0
	radiation.modulate.a = 0.0


func _physics_process(_delta: float) -> void:
	_update_data(genome_ref)


func _update_data(genome: Genome) -> void:
	if not genome:
		return
	var params: Dictionary[String, Variant] = genome.get_param_dict()
	var ranges: Dictionary = genome.get_ranges_dict()
	if not ranges:
		return
	if params.has("Fire"):
		fire.modulate.a = _get_percentage(params.get("Fire"), ranges.get("Fire") as Array)
	if params.has("Ice"):
		ice.modulate.a = _get_percentage(params.get("Ice"), ranges.get("Ice")  as Array)
	if params.has("Radiation"):
		radiation.modulate.a = _get_percentage(params.get("Radiation"), ranges.get("Radiation")  as Array)


func _get_percentage(value: Variant, ranges: Array[Variant]) -> float:
	return (value - ranges[0]) / (ranges[1] - ranges[0])
