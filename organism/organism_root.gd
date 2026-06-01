extends Node2D

const ORGANISM_PHYSICS := preload("res://organism/character_body_2d.gd")
const ORGANS_MANAGER := preload("res://organism/organs_manager.gd")
const FOOD_SCENE: PackedScene = preload("res://food/food.tscn")
const FOOD_CLASS := preload("res://food/food.gd")
const ORGANISM_BLACKBOARD := preload("res://organism/beehave_tree/blackboard.gd")

@export var energy: float = 15.0
@export var hp: float = 100.0

@export var genome: Array[Gene]:
	set(value):
		genome = value

		if not is_inside_tree():
			return

		_update_genome()

@onready var character_body: ORGANISM_PHYSICS = $CharacterBody2D
@onready var organs_manager: ORGANS_MANAGER = $CharacterBody2D/OrgansManager
@onready var blackboard: ORGANISM_BLACKBOARD = $Blackboard


func _ready() -> void:
	force_update_genome()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if organs_manager == null:
		return

	# energy
	energy -= delta * organs_manager.get_total_energy_consumption()
	if energy < 0.0:
		queue_free()

	if hp < 0.0:
		kill()


## Убить организм и высвободить оставшуюся энергию.
func kill() -> void:
	while energy > 0.0:
		var food: FOOD_CLASS = FOOD_SCENE.instantiate()
		var food_energy: float = min(energy, food.energy)
		energy -= food_energy
		food.energy = food_energy
		var food_spawner: Node = get_node(^"../../../FoodSpawner")
		food_spawner.add_child(food)
		food.global_position = character_body.global_position
		food.set_random_velocity()
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
