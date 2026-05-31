@abstract
extends Object
## Namespace с функциями и классами для генетического алгоритма.

const RNG = preload("res://etc/random.gd")


## Обработать геном [param genome] по типам с обработчиками из [param type_parsers].
## В [Callable] из [param type_parsers] передаётся [GenesTable.TypeArr] в качестве
## единственного аргумента. Возвращает массив с ошибками, если таковые имеются.
static func parse_genome(
		genome: Array[Gene],
		type_parsers: Dictionary[StringName, Callable],
) -> PackedStringArray:
	var warnings: PackedStringArray = []
	var genes_table := GenesTable.new(genome)
	for type: StringName in genes_table.data:
		if type not in type_parsers:
			var msg := "Отсутствует обработчик для гена с типом &'{0}'".format([type])
			var _err := warnings.append(msg)
			if not Engine.is_editor_hint():
				Log.warn(msg)
			continue
		var type_arr: GenesTable.TypeArr = genes_table.get_all_type_data_or_assert(type)
		type_parsers[type].call(type_arr)
	return warnings


## Конкатенация двух таблиц с генами. Возвращается новая таблица, данные которой не привязаны
## к входным таблицам [param genome1] и [param genome2].
static func splice_gene_tables(genome1: GenesTable, genome2: GenesTable) -> GenesTable:
	var res: GenesTable = genome1.duplicate()
	var other: GenesTable = genome2.duplicate()
	for type: StringName in other.get_all_types():
		if not res.has_type(type):
			res.add_type_data(type)
		res.append_type_arr(type, other.get_all_type_data(type))
	return res


## Конкатенация двух массивов генов. Исходные массивы не меняются, возвращается новый массив.
## Индексы меняются в случае совпадений.
static func splice_genes(genome1: Array[Gene], genome2: Array[Gene]) -> Array[Gene]:
	var table1 := GenesTable.new(genome1)
	var table2 := GenesTable.new(genome2)
	return splice_gene_tables(table1, table2).into_array_of_genes()


## Удаляет дубликаты для одиночных типов из [param singular_types].
static func ensure_singular_types(
		genome: Array[Gene],
		singular_types: Array[StringName],
) -> int:
	var for_deletion: Array[int] = []
	for type: StringName in singular_types:
		var properties_set: Dictionary[StringName, bool] = { }
		for i in range(genome.size()):
			var gene: Gene = genome[i]
			if gene.type != type:
				continue
			if properties_set.has(gene.name):
				for_deletion.append(i)
			else:
				properties_set[gene.name] = true
	var new_genome: Array[Gene] = []
	for i in range(genome.size()):
		if i in for_deletion:
			continue
		new_genome.append(genome[i])
	var cnt: int = genome.size() - new_genome.size()
	genome.assign(new_genome)
	return cnt


## Находит все названия параметров [member Gene.name] для указанного типа [param type] в
## предоставленном геноме [param genome].
static func find_type_properties(genome: Array[Gene], type: StringName) -> Array[StringName]:
	var name_set: Dictionary[StringName, bool] = { }
	for gene: Gene in genome:
		if gene.type == type:
			name_set[gene.name] = true
	return name_set.keys()


## Случайно выбирает [Gene] из массива [param genome], удаляет его и другие гены такого
## же типа и индекса. Типы из [param exclude_types] не будут удалены.
## (Это не cut из m-GA).
static func random_cut(genome: Array[Gene], exclude_types: Array[StringName]) -> Array[Gene]:
	var exclude_filter: Callable = func(gene: Gene) -> bool:
		return gene.type not in exclude_types

	var genome_without_exclude_types: Array[Gene] = genome.filter(exclude_filter)
	if genome_without_exclude_types.is_empty():
		return genome.duplicate(true)

	var rand_gene: Gene = genome_without_exclude_types.pick_random()
	return remove_type_instance_from_genes(genome, rand_gene.type, rand_gene.index)


## Из массива генов [Gene] удаляет все параметры типа [param type]
## с указанным индексом [param index].
static func remove_type_instance_from_genes(
		genome: Array[Gene],
		type: StringName,
		index: int,
) -> Array[Gene]:
	var exclude_type_index: Callable = func(gene: Gene) -> bool:
		return gene.type != type or gene.index != index
	return genome.filter(exclude_type_index)


## Рекомбинация (линейная интерполяция) вещественного параметра.
static func alpha_recombinationf(paramf1: float, paramf2: float, d: float = 0.25) -> float:
	var alpha: float = randf_range(-d, 1 + d)
	return lerpf(paramf1, paramf2, alpha)


## Мутация для вещественных чисел.
static func real_value_mutation(value: float, val_range: float, iter: int) -> float:
	assert(iter >= 1)
	var alpha: float = 0.5 * val_range
	alpha *= [1, -1].pick_random()

	var calc_delta: Callable = func(m: int) -> float:
		var res := 0.0
		for i: int in range(1, m + 1):
			if RNG.roll_dice(1.0 / m):
				res += pow(2.0, -i)
		return res

	return value + alpha * calc_delta.call(iter)
