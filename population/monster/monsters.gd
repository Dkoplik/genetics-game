class_name Monsters extends Node

var monster_scene: PackedScene = preload("res://population/monster/monster.tscn")
var timer: EOWTimer
var wave: int = 0

# TODO сделать настройку через Inspector
var monsters_data: Array[Array] = [
	[
		_new_monster_params(
			100.0,
			0.5,
			Color("d9311a3c"),
			"30 - 0.9284 * pow(Fire, 2.0/3) - pow(Fire, 0.5)",
			PackedStringArray(["Fire"])
		),
		_new_monster_params(
			100.0,
			0.5,
			Color("d9311a3c"),
			"30 - 0.9284 * pow(Fire, 2.0/3) - pow(Fire, 0.5)",
			PackedStringArray(["Fire"])
		)
	],
	[
		_new_monster_params(
			100.0,
			0.5,
			Color("1a66d93c"),
			"6.47 * pow(Ice, 1.0/3)",
			PackedStringArray(["Ice"])
		),
		_new_monster_params(
			100.0,
			0.5,
			Color("1a66d93c"),
			"6.47 * pow(Ice, 1.0/3)",
			PackedStringArray(["Ice"])
		)
	],
	[
		_new_monster_params(
			100.0,
			0.5,
			Color("acd91a3c"),
			"2.21 * pow(pow(Radiation - 50, 2.0), 1.0/3)",
			PackedStringArray(["Radiation"])
		),
		_new_monster_params(
			100.0,
			0.5,
			Color("acd91a3c"),
			"2.21 * pow(pow(Radiation - 50, 2.0), 1.0/3)",
			PackedStringArray(["Radiation"])
		)
	],
	[
		_new_monster_params(
			100.0,
			0.5,
			Color("d9311a3c"),
			"30 - 0.9284 * pow(Fire, 2.0/3) - pow(Fire, 0.5)",
			PackedStringArray(["Fire"])
		),
		_new_monster_params(
			100.0,
			0.5,
			Color("1a66d93c"),
			"6.47 * pow(Ice, 1.0/3)",
			PackedStringArray(["Ice"])
		),
		_new_monster_params(
			100.0,
			0.5,
			Color("acd91a3c"),
			"2.21 * pow(pow(Radiation - 50, 2.0), 1.0/3)",
			PackedStringArray(["Radiation"])
		),
		_new_monster_params(
			100.0,
			0.5,
			Color("acd91a3c"),
			"2.21 * pow(pow(Radiation - 50, 2.0), 1.0/3)",
			PackedStringArray(["Radiation"])
		),
		_new_monster_params(
			100.0,
			0.5,
			Color("1a66d93c"),
			"6.47 * pow(Ice, 1.0/3)",
			PackedStringArray(["Ice"])
		),
		_new_monster_params(
			100.0,
			0.5,
			Color("d9311a3c"),
			"30 - 0.9284 * pow(Fire, 2.0/3) - pow(Fire, 0.5)",
			PackedStringArray(["Fire"])
		)
	]
]


func start(new_timer: EOWTimer) -> void:
	timer = new_timer
	timer.started_eow.connect(next_wave)
	timer.start(45.0)


func next_wave() -> void:
	var monster_wave: Array = monsters_data[wave]
	for monster_params: MonsterParams in monster_wave:
		var monster: Monster = monster_scene.instantiate()
		monster.params = monster_params
		monster.population = $"../Population"
		self.add_child(monster)
		monster.behaviour.position = Vector2(500, 650)

		var spawn_timer: SceneTreeTimer = get_tree().create_timer(1.5)
		await spawn_timer.timeout

	wave += 1
	if wave < monsters_data.size():
		timer.start(90.0)


func _new_monster_params(hp: float, damage: float, color: Color, function: String, variables: PackedStringArray) -> MonsterParams:
	var params := MonsterParams.new()
	params.max_hp = hp
	params.monster_damage = damage
	
	var monster_effect := EffectData.new()
	monster_effect.name = "Monster"
	monster_effect.color = color
	monster_effect.function = function
	monster_effect.variables = variables
	monster_effect.duration = Numeric.FLOAT_MAX
	params.effect = monster_effect
	
	return params
