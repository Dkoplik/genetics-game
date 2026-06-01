@tool
extends Area2D
## Рот/челюсть/клещни организма. Позволяют атаковать другие организмы.

const ORGANISM_CLASS := preload("res://organism/organism_root.gd")
const ORGANISM_PHYSICS := preload("res://organism/character_body_2d.gd")
const ORGANS_MANAGER := preload("res://organism/organs_manager.gd")
const ORGANISM_ARMOR := preload("res://organism/armor.gd")

@export var min_size: float = 0.25:
	set(value):
		min_size = max(0.0, value)

		if min_size > max_size:
			max_size = min_size

		if energy_consumption_vs_size != null:
			energy_consumption_vs_size.min_domain = min_size

		if damage_vs_size != null:
			damage_vs_size.min_domain = min_size

@export var max_size: float = 2.0:
	set(value):
		max_size = max(0.0, value)

		if min_size > max_size:
			min_size = max_size

		if energy_consumption_vs_size != null:
			energy_consumption_vs_size.max_domain = max_size

		if damage_vs_size != null:
			damage_vs_size.max_domain = max_size

## Размер организма.
@export var size: float = 1.0:
	set(value):
		size = clampf(value, min_size, max_size)
		_update_consumption()
		_update_damage()
		scale = Vector2(size, size)

## Кривая зависимости между потреблением энергии (Y) и размером (X).
@export var energy_consumption_vs_size: Curve:
	set(value):
		if energy_consumption_vs_size != null:
			energy_consumption_vs_size.changed.disconnect(_update_consumption)

		energy_consumption_vs_size = value
		_process_curve(energy_consumption_vs_size, _update_consumption)
		_update_consumption()
		if Engine.is_editor_hint():
			update_configuration_warnings()

## Кривая зависимости между уроном (Y) и размером (X).
@export var damage_vs_size: Curve:
	set(value):
		if damage_vs_size != null:
			damage_vs_size.changed.disconnect(_update_damage)

		damage_vs_size = value
		_process_curve(damage_vs_size, _update_damage)
		_update_damage()
		if Engine.is_editor_hint():
			update_configuration_warnings()

## Потребление энергии в секунду.
@export_custom(
	PROPERTY_HINT_NONE,
	"suffix:per sec",
	PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
)
var energy_consumption: float:
	set(value):
		if value < 0.0:
			Log.warn("Попытка сделать energy_consumption отрицательным")
			value = 0.0
		energy_consumption = value

## Урон за один удар.
@export_custom(
	PROPERTY_HINT_NONE,
	"suffix:hp per hit",
	PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
)
var damage: float:
	set(value):
		if value < 0.0:
			Log.warn("Попытка сделать damage отрицательным")
			value = 0.0
		damage = value


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var _err := body_entered.connect(_on_organism_collide)
	_err = area_entered.connect(_on_armor_collide)


func _update_consumption() -> void:
	if energy_consumption_vs_size != null:
		if energy_consumption_vs_size.point_count == 0:
			Log.warn("В кривой energy_consumption_vs_size отсутствуют точки")
		energy_consumption = energy_consumption_vs_size.sample(size)
	elif not Engine.is_editor_hint():
		Log.err("Попытка обновить energy_consumption без кривой energy_consumption_vs_size")


func _update_damage() -> void:
	if damage_vs_size != null:
		if damage_vs_size.point_count == 0:
			Log.warn("В кривой damage_vs_size отсутствуют точки")
		damage = damage_vs_size.sample(size)
	elif not Engine.is_editor_hint():
		Log.err("Попытка обновить rotation_speed без кривой damage_vs_size")


func _process_curve(curve: Curve, updater: Callable) -> void:
	if curve == null:
		return

	curve.min_domain = min_size
	curve.max_domain = max_size
	var _err: int = curve.changed.connect(updater)


func _on_armor_collide(area: Area2D) -> void:
	if area is not ORGANISM_ARMOR:
		return

	var collided_body: ORGANISM_PHYSICS = area.get_parent().get_parent().get_parent()
	var my_body: ORGANISM_PHYSICS = get_parent().get_parent().get_parent()
	if is_same(collided_body, my_body):
		return

	if collided_body.get_parent() is not ORGANISM_CLASS:
		Log.err("У CharacterBody2D организма корень не организм")
		return

	# knockback
	var organism: ORGANISM_CLASS = collided_body.get_parent()
	var organs_manager: ORGANS_MANAGER = organism.organs_manager
	var global_direction: Vector2 = global_transform.basis_xform(Vector2.RIGHT).normalized()
	my_body.velocity = -global_direction * 2.5 * organs_manager.get_total_speed()


func _on_organism_collide(body: Node2D) -> void:
	if body is not ORGANISM_PHYSICS:
		return

	var my_body: ORGANISM_PHYSICS = get_parent().get_parent().get_parent()
	if is_same(body, my_body):
		return

	if body.get_parent() is not ORGANISM_CLASS:
		Log.err("У CharacterBody2D организма корень не организм")
		return

	# damage
	var organism_physics: ORGANISM_PHYSICS = body
	var organism: ORGANISM_CLASS = organism_physics.get_parent()
	organism.hp -= damage

	# knockback
	var organs_manager: ORGANS_MANAGER = organism.organs_manager
	var global_direction: Vector2 = global_transform.basis_xform(Vector2.RIGHT).normalized()
	organism_physics.velocity = global_direction * 2.5 * organs_manager.get_total_speed()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if energy_consumption_vs_size == null:
		var _tmp: bool = warnings.append("Отсутствует график зависимости потребления от размера")
	if damage_vs_size == null:
		var _tmp: bool = warnings.append(
			"Отсутствует график зависимости урона от размера",
		)
	return warnings
