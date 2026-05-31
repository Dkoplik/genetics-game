extends Node

const ORGANISM_PHYSICS := preload("res://organism/character_body_2d.gd")
const ORGANS_MANAGER := preload("res://organism/organs_manager.gd")

@export var energy: float = 15.0

@export var genome: Array[Gene]:
	set(value):
		genome = value

		if not is_inside_tree():
			return

		_update_genome()

@onready var character_body: ORGANISM_PHYSICS = $CharacterBody2D
@onready var organs_manager: ORGANS_MANAGER = $CharacterBody2D/OrgansManager


func _ready() -> void:
	force_update_genome()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	# energy
	energy -= delta * organs_manager.get_total_energy_consumption()
	if energy < 0.0:
		queue_free()


## [member genome] автоматически обрабатывается при изменении, но при этом
## обновление не происходит если изменилось содержимое [member genome], а не сам
## массив. На этот случай можно вручную обновить состояние организма.
func force_update_genome() -> void:
	_update_genome()


func _update_genome() -> void:
	if organs_manager == null:
		Log.err("Отсутствует OrgansManager, невозможно обработать геном")
		return

	if genome == null:
		Log.err("Геном отсутствует")
		return

	var warnings: PackedStringArray = organs_manager.parse_genome(genome)
	if not warnings.is_empty():
		Log.warn("При обновлении генома возникли следующие ошибки:", warnings)
