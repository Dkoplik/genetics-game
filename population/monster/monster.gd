class_name Monster extends Node

signal died(this: Monster)
signal hp_changed(new_hp: float)

## Остальные параметры монстра.
var params: MonsterParams = preload("res://config/monster-params.tres")
var effect_scene: PackedScene = preload("res://population/monster/monster-effect/monster-effect.tscn")
var population: Population
var effect: LocalEffect

## Время жизни монстра.
var _time_alive: float = 0.0
## Текущие жизни монстра.
var _hp: float:
	get = get_hp,
	set = set_hp

## Узел (класс) с поведением монстра в игровом мире.
@onready var behaviour := $Monster2D as Monster2D
@onready var sprite := $Monster2D/MonsterSprite as Sprite2D

func _ready() -> void:
	_hp = params.max_hp

	var color: Color = params.effect.color
	color.a = clampf(color.a + 0.5, 0.0, 1.0)
	sprite.modulate = color

	effect = effect_scene.instantiate()
	effect.data = params.effect
	behaviour.add_child(effect)

	_move_to_new_organism()
	behaviour.lost_target.connect(_move_to_new_organism)


func _physics_process(delta: float) -> void:
	_time_alive += delta
	var damage: float = _calc_damage()
	if damage > 0.0:
		deal_damage(damage)


func get_closest_organism2d() -> Organism2D:
	var organisms: Array[Organism] = population.get_organisms()
	var closest_organism: Organism2D = null
	for organism in organisms:
		var organism_2d: Organism2D = organism.behaviour
		if closest_organism == null:
			closest_organism = organism_2d
			continue
		var dist_to_closest: float = behaviour.global_position.distance_to(closest_organism.global_position)
		var dist_to_current: float = behaviour.global_position.distance_to(organism_2d.global_position)
		if dist_to_current < dist_to_closest:
			closest_organism = organism_2d
	return closest_organism


## Запустить вымирание монстра. После вызова этого метода монстр должен
## осободить все занимаемые ресурсы и исчезнуть.
func die() -> void:
	died.emit(self)
	self.queue_free()


## Время жизни монстра.
func get_time_alive() -> float:
	return _time_alive


## Нанести урон в размере [param damage].
func deal_damage(damage: float) -> void:
	if damage <= 0.0:
		push_error("урон = {0}".format([damage]))
		return
	_hp -= damage


## Увеличить здоровье на [param heal_amount].
func heal(heal_amount: float) -> void:
	if heal_amount <= 0.0:
		push_error("восстановление жизней = {0}".format([heal_amount]))
		return
	_hp += heal_amount


func set_hp(new_hp: float) -> void:
	_hp = clampf(new_hp, 0.0, params.max_hp)
	hp_changed.emit(_hp)
	if _hp == 0.0:
		die()


func get_hp() -> float:
	return _hp


func _move_to_new_organism() -> void:
	var closest_organism: Organism2D = get_closest_organism2d()
	if closest_organism == null:
		push_warning("не обнаружено никаких организмов")
		return
	behaviour.move_to_organism2d(closest_organism)


func _calc_damage() -> float:
	return params.monster_damage * effect.organisms.size()
