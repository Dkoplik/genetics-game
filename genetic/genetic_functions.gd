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


## Соединяет два генома в новый. Операция объединяет в себе [method splice_genes] и
## последовательные [method random_cut], дабы уместить размер нового генома в диапазон.[br]
##
## [param genome1] - 1-ый родительский геном. Не изменяется.[br]
##
## [param genome1] - 2-ой родительский геном. Не изменяется.[br]
##
## [param singular_types] - какие типы надо удалить после [method splice_genes] через
## метод [method ensure_singular_types].[br]
##
## [param exclude_types] - какие типы нельзя удалять через [method random_cut].[br]
##
## [param probability_curve] - зависимость вероятности вызова [method random_cut] от размера
## генома. Ось X должна быть в диапазоне [lb]0, 1[rb], где 0 - нижняя граница размера генома, а
## 1 - верхняя граница.[br]
##
## [param d] - коэффициент для задания диапазона размера будущего генома. Итоговый диапазон
## определяется как [lb]min(genome1, genome2) * (1 - d), max(genome1, genome2) * (1 + d)[rb]
static func mix_genes(
		genome1: Array[Gene],
		genome2: Array[Gene],
		singular_types: Array[StringName],
		exclude_types: Array[StringName],
		probability_curve: Curve,
		d: float = 0.25,
) -> Array[Gene]:
	var spliced_genome: Array[Gene] = splice_genes(genome1, genome2)
	var _cnt := ensure_singular_types(spliced_genome, singular_types)

	var max_size: int = maxi(roundi((1 + d) * maxi(genome1.size(), genome2.size())), 0)
	var min_size: int = clampi(roundi((1 - d) * mini(genome1.size(), genome2.size())), 0, max_size)

	var normalize_size_lambda: Callable = func(size: int) -> float:
		return float((size - min_size)) / float((max_size - min_size))

	while true:
		var cur_size: int = spliced_genome.size()
		var nsize: float = normalize_size_lambda.call(cur_size)
		var p_cut: float = clampf(0.8 * nsize, 0.0, 1.0)
		if probability_curve != null:
			p_cut = clampf(probability_curve.sample(nsize), 0.0, 1.0)

		if not RNG.roll_dice(p_cut):
			break

		var cut_genome: Array[Gene] = random_cut(spliced_genome, exclude_types)
		var size_diff: int = spliced_genome.size() - cut_genome.size()
		if size_diff == 0: # ничего не было удалено, нет смысла дальше пытаться
			break
		spliced_genome.assign(cut_genome)

	return spliced_genome


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
		var res: Array[Gene] = []
		for gene: Gene in genome:
			res.push_back(gene.duplicate())
		return res

	var rand_gene: Gene = genome_without_exclude_types.pick_random()
	return remove_type_instance_from_genes(genome, rand_gene.type, rand_gene.index)


## Из массива генов [Gene] удаляет все параметры типа [param type]
## с указанным индексом [param index]. Возвращает новый массив.
static func remove_type_instance_from_genes(
		genome: Array[Gene],
		type: StringName,
		index: int,
) -> Array[Gene]:
	var exclude_type_index: Callable = func(gene: Gene) -> bool:
		return gene.type != type or gene.index != index
	var filtered_genome: Array[Gene] = genome.filter(exclude_type_index)

	var res: Array[Gene] = []
	for gene: Gene in filtered_genome:
		res.push_back(gene.duplicate())
	return res


## Рекомбинация (линейная интерполяция) вещественного параметра.
static func alpha_recombinationf(paramf1: float, paramf2: float, d: float = 0.25) -> float:
	var alpha: float = randf_range(-d, 1 + d)
	return lerpf(paramf1, paramf2, alpha)


## Мутирует значение случайного гена из [param genome]. Диапазон мутации берётся из
## [param gene_ranges].
static func mutate_random_gene(
		genome: Array[Gene],
		gene_ranges: GeneRanges,
		iter: int = 12,
) -> void:
	if genome.is_empty():
		return

	var gene: Gene = genome.pick_random()
	var val_range: float = 100.0
	if gene_ranges != null and gene_ranges.has_gene(gene.type, gene.name):
		var minmax: GeneMinMax = gene_ranges.get_gene_minmax(gene.type, gene.name)
		val_range = minmax.value_range()
	gene.value = real_value_mutation(gene.value, val_range, iter)


## Мутация для вещественных чисел.
static func real_value_mutation(value: float, val_range: float, iter: int) -> float:
	assert(iter >= 1)
	var alpha: float = val_range / 2.0
	alpha *= [1, -1].pick_random()

	var calc_delta: Callable = func(m: int) -> float:
		var res := 0.0
		for i: int in range(1, m + 1):
			if RNG.roll_dice(1.0 / m):
				res += pow(2.0, -i)
		return res

	return value + alpha * sign(alpha) * calc_delta.call(iter)


## Добавляет случайный тип гена в [param genome]. Набор существующих типов и их поля берутся
## из [param gene_ranges], оттуда же берутся возможные диапазоны значений полей. Новые гены
## будут со случайными параметрами. [param exclude_types] исключают типы из добавления.
static func add_random_gene(
		genome: Array[Gene],
		gene_ranges: GeneRanges,
		exclude_types: Array[StringName],
) -> void:
	if gene_ranges == null or gene_ranges.gene_ranges == null:
		return

	var existing_types: Array[StringName] = gene_ranges.gene_ranges.keys()
	var possible_types: Array[StringName]
	if exclude_types != null and not exclude_types.is_empty():
		var exclude_type_lamda: Callable = func(type: StringName) -> bool:
			return not exclude_types.has(type)
		possible_types = existing_types.filter(exclude_type_lamda)
	else:
		possible_types = existing_types

	if possible_types.is_empty():
		return

	var type_to_add: StringName = possible_types.pick_random()
	if not gene_ranges.gene_ranges.has(type_to_add):
		return

	var occupied_indexes: Dictionary[int, bool] = { } # set
	for gene: Gene in genome:
		if gene.type != type_to_add:
			continue
		occupied_indexes[gene.index] = true
	occupied_indexes.sort()
	var new_index: int = 0
	while occupied_indexes.has(new_index):
		new_index += 1

	var type_ranges: TypeRanges = gene_ranges.gene_ranges[type_to_add]
	var property_names: Array[StringName] = type_ranges.ranges_for_type.keys()
	for name: StringName in property_names:
		var minmax: GeneMinMax = gene_ranges.get_gene_minmax(type_to_add, name)
		var value: float = randf_range(minmax.min_value, minmax.max_value)
		var new_gene := Gene.new(type_to_add, name, new_index, value)
		genome.append(new_gene)
