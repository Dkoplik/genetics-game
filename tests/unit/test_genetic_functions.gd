extends GutTest

const GA = preload("res://genetic/genetic_functions.gd")

const TEST_TYPE_1: StringName = &"Organ"
const TEST_TYPE_2: StringName = &"Leg"
const TEST_TYPE_3: StringName = &"Eye"
const SINGULAR_TYPE: StringName = &"Body"


class TestParseGenome:
	extends GutTest

	func test_empty_genome() -> void:
		var fail_lambda: Callable = func(_arr: GenesTable.TypeArr) -> void:
			fail_test("Эта функция не должна вызываться")
		var type_parsers: Dictionary[StringName, Callable] = {
			TEST_TYPE_1: fail_lambda,
			TEST_TYPE_2: fail_lambda,
			TEST_TYPE_3: fail_lambda,
		}
		var genes: Array[Gene] = []
		var warnings: PackedStringArray = GA.parse_genome(genes, type_parsers)
		assert_true(warnings.is_empty(), "Не должно быть предупреждений")


	func test_single_type_genome() -> void:
		var fail_lambda: Callable = func(_arr: GenesTable.TypeArr) -> void:
			fail_test("Эта функция не должна вызываться")

		var cnt: Dictionary[StringName, int] = { }
		var type_counter_lambda: Callable = func(
				_arr: GenesTable.TypeArr,
				type: StringName,
		) -> void:
			cnt[type] = cnt.get(type, 0) + 1

		var type_parsers: Dictionary[StringName, Callable] = {
			TEST_TYPE_1: type_counter_lambda.bind(TEST_TYPE_1),
			TEST_TYPE_2: fail_lambda,
			TEST_TYPE_3: fail_lambda,
		}
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var warnings: PackedStringArray = GA.parse_genome(genes, type_parsers)

		assert_eq(cnt[TEST_TYPE_1], 1)
		assert_true(warnings.is_empty(), "Не должно быть предупреждений")


	func test_single_type_multiple_index_genome() -> void:
		var fail_lambda: Callable = func(_arr: GenesTable.TypeArr) -> void:
			fail_test("Эта функция не должна вызываться")

		var cnt: Dictionary[StringName, int] = { }
		var type_counter_lambda: Callable = func(
				_arr: GenesTable.TypeArr,
				type: StringName,
		) -> void:
			cnt[type] = cnt.get(type, 0) + 1

		var type_parsers: Dictionary[StringName, Callable] = {
			TEST_TYPE_1: type_counter_lambda.bind(TEST_TYPE_1),
			TEST_TYPE_2: fail_lambda,
			TEST_TYPE_3: fail_lambda,
		}
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"health", 1, 100.0),
			Gene.new(TEST_TYPE_1, &"health", 2, 100.0),
		]
		var warnings: PackedStringArray = GA.parse_genome(genes, type_parsers)

		assert_eq(cnt[TEST_TYPE_1], 1)
		assert_true(warnings.is_empty(), "Не должно быть предупреждений")


	func test_multiple_type_genome() -> void:
		var cnt: Dictionary[StringName, int] = { }
		var type_counter_lambda: Callable = func(
				_arr: GenesTable.TypeArr,
				type: StringName,
		) -> void:
			cnt[type] = cnt.get(type, 0) + 1

		var type_parsers: Dictionary[StringName, Callable] = {
			TEST_TYPE_1: type_counter_lambda.bind(TEST_TYPE_1),
			TEST_TYPE_2: type_counter_lambda.bind(TEST_TYPE_2),
			TEST_TYPE_3: type_counter_lambda.bind(TEST_TYPE_3),
		}
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"health", 1, 100.0),
			Gene.new(TEST_TYPE_3, &"health", 2, 100.0),
		]
		var warnings: PackedStringArray = GA.parse_genome(genes, type_parsers)

		assert_eq(cnt[TEST_TYPE_1], 1)
		assert_eq(cnt[TEST_TYPE_2], 1)
		assert_eq(cnt[TEST_TYPE_3], 1)
		assert_true(warnings.is_empty(), "Не должно быть предупреждений")

	func test_no_available_type_parser() -> void:
		var cnt: Dictionary[StringName, int] = { }
		var type_counter_lambda: Callable = func(
				_arr: GenesTable.TypeArr,
				type: StringName,
		) -> void:
			cnt[type] = cnt.get(type, 0) + 1

		var type_parsers: Dictionary[StringName, Callable] = {
			TEST_TYPE_1: type_counter_lambda.bind(TEST_TYPE_1),
			TEST_TYPE_2: type_counter_lambda.bind(TEST_TYPE_2),
			# для TEST_TYPE_3 отсутствует
		}
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"health", 1, 100.0),
			Gene.new(TEST_TYPE_3, &"health", 2, 100.0),
		]
		var warnings: PackedStringArray = GA.parse_genome(genes, type_parsers)

		assert_eq(cnt[TEST_TYPE_1], 1)
		assert_eq(cnt[TEST_TYPE_2], 1)
		assert_eq(warnings.size(), 1, "Должно быть предупреждение об отсутствии парсера")
		assert_has(warnings, "Отсутствует обработчик для гена с типом &'{0}'".format([TEST_TYPE_3]))


class TestSplicesGenesTables:
	extends GutTest

	func test_empty_splice_empty() -> void:
		var table1 := GenesTable.new([])
		var table2 := GenesTable.new([])
		var res_table: GenesTable = GA.splice_gene_tables(table1, table2)

		assert_eq(res_table.get_types_amount(), 0)


	func test_single_type_splice_empty() -> void:
		var genes1: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_1, &"health", 2, 300.0),
		]
		var table1 := GenesTable.new(genes1)
		var table2 := GenesTable.new([])
		var res_table: GenesTable = GA.splice_gene_tables(table1, table2)

		assert_eq(res_table.get_types_amount(), 1)
		assert_true(res_table.has_type(TEST_TYPE_1))
		assert_eq(res_table.get_type_arr_size(TEST_TYPE_1), 3)
		assert_eq(res_table.get_type_data_or_assert(TEST_TYPE_1, 0)[&"health"], 100.0)
		assert_eq(res_table.get_type_data_or_assert(TEST_TYPE_1, 1)[&"health"], 200.0)
		assert_eq(res_table.get_type_data_or_assert(TEST_TYPE_1, 2)[&"health"], 300.0)


	func test_empty_splice_single_type() -> void:
		var table1 := GenesTable.new([])
		var genes2: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_1, &"health", 2, 300.0),
		]
		var table2 := GenesTable.new(genes2)
		var res_table: GenesTable = GA.splice_gene_tables(table1, table2)

		assert_eq(res_table.get_types_amount(), 1)
		assert_true(res_table.has_type(TEST_TYPE_1))
		assert_eq(res_table.get_type_arr_size(TEST_TYPE_1), 3)
		assert_eq(res_table.get_type_data_or_assert(TEST_TYPE_1, 0)[&"health"], 100.0)
		assert_eq(res_table.get_type_data_or_assert(TEST_TYPE_1, 1)[&"health"], 200.0)
		assert_eq(res_table.get_type_data_or_assert(TEST_TYPE_1, 2)[&"health"], 300.0)


	func test_multitype_splice_multitype() -> void:
		var genes1: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"size", 0, 200.0),
		]
		var table1 := GenesTable.new(genes1)

		var genes2: Array[Gene] = [
			Gene.new(TEST_TYPE_2, &"size", 0, 100.0),
			Gene.new(TEST_TYPE_3, &"speed", 0, 200.0),
		]
		var table2 := GenesTable.new(genes2)
		var res_table: GenesTable = GA.splice_gene_tables(table1, table2)

		assert_eq(res_table.get_types_amount(), 3)
		assert_true(res_table.has_type(TEST_TYPE_1))
		assert_true(res_table.has_type(TEST_TYPE_2))
		assert_true(res_table.has_type(TEST_TYPE_3))

		assert_eq(res_table.get_type_arr_size(TEST_TYPE_1), 1)
		assert_eq(res_table.get_type_arr_size(TEST_TYPE_2), 2)
		assert_eq(res_table.get_type_arr_size(TEST_TYPE_3), 1)

		assert_eq(res_table.get_type_data_or_assert(TEST_TYPE_1, 0)[&"health"], 100.0)
		assert_eq(res_table.get_type_data_or_assert(TEST_TYPE_3, 0)[&"speed"], 200.0)


	func test_result_is_not_reference() -> void:
		var genes1: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"size", 0, 200.0),
		]
		var table1 := GenesTable.new(genes1)

		var genes2: Array[Gene] = [
			Gene.new(TEST_TYPE_2, &"size", 0, 100.0),
			Gene.new(TEST_TYPE_3, &"speed", 0, 200.0),
		]
		var table2 := GenesTable.new(genes2)
		var res_table: GenesTable = GA.splice_gene_tables(table1, table2)

		table1.set_type_data(TEST_TYPE_1, 0, { &"speed": 50.0 })
		assert_eq(res_table.get_type_data_or_assert(TEST_TYPE_1, 0)[&"health"], 100.0)

		table2.get_type_data_or_assert(TEST_TYPE_3, 0)[&"speed"] = -100.0
		assert_eq(res_table.get_type_data_or_assert(TEST_TYPE_3, 0)[&"speed"], 200.0)


class TestSpliceGenes:
	extends GutTest

	func test_splice_genes_empty() -> void:
		var genome1: Array[Gene] = []
		var genome2: Array[Gene] = []
		var result: Array[Gene] = GA.splice_genes(genome1, genome2)

		assert_eq(result.size(), 0, "Результат должен быть пустым")
		assert_not_same(result, genome1, "Должен быть новый массив")


	func test_splice_genes_basic() -> void:
		var genome1: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var genome2: Array[Gene] = [
			Gene.new(TEST_TYPE_2, &"speed", 0, 50.0),
		]
		var result: Array[Gene] = GA.splice_genes(genome1, genome2)

		assert_eq(result.size(), 2, "Должно быть два гена")
		assert_eq(result[0].value, 100.0)
		assert_eq(result[1].value, 50.0)


	func test_splice_genes_does_not_modify_originals() -> void:
		var genome1: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var genome2: Array[Gene] = [
			Gene.new(TEST_TYPE_2, &"speed", 0, 50.0),
		]
		var original1_size: int = genome1.size()
		var original2_size: int = genome2.size()

		var _res: Array[Gene] = GA.splice_genes(genome1, genome2)

		assert_eq(genome1.size(), original1_size, "Исходный массив не должен измениться")
		assert_eq(genome2.size(), original2_size, "Исходный массив не должен измениться")


	func test_splice_genes_changes_indexes() -> void:
		var genome1: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var genome2: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 50.0),
		]
		var result: Array[Gene] = GA.splice_genes(genome1, genome2)

		assert_ne(result[0].index, result[1].index, "Гены не были переиндексированы")


class TestSingularTypes:
	extends GutTest
	func test_ensure_singular_types_no_duplicates() -> void:
		var genome: Array[Gene] = [
			Gene.new(SINGULAR_TYPE, &"health", 0, 100.0),
			Gene.new(SINGULAR_TYPE, &"speed", 0, 50.0),
		]
		var singular_types: Array[StringName] = [SINGULAR_TYPE]

		var removed_cnt: int = GA.ensure_singular_types(genome, singular_types)

		assert_eq(removed_cnt, 0, "Не должно быть удалённых генов")
		assert_eq(genome.size(), 2, "Размер не должен измениться")


	func test_ensure_singular_types_with_duplicates() -> void:
		var genome: Array[Gene] = [
			Gene.new(SINGULAR_TYPE, &"health", 0, 100.0),
			Gene.new(SINGULAR_TYPE, &"health", 1, 200.0), # дубликат
			Gene.new(SINGULAR_TYPE, &"speed", 0, 50.0),
		]
		var singular_types: Array[StringName] = [SINGULAR_TYPE]

		var removed_cnt: int = GA.ensure_singular_types(genome, singular_types)

		assert_eq(removed_cnt, 1, "Должен быть удалён один дубликат")
		assert_eq(genome.size(), 2, "После удаления должно быть 2 гена")


	func test_ensure_singular_types_multiple_types() -> void:
		var genome: Array[Gene] = [
			Gene.new(SINGULAR_TYPE, &"health", 0, 100.0),
			Gene.new(SINGULAR_TYPE, &"health", 1, 200.0), # дубликат
			Gene.new(TEST_TYPE_1, &"size", 0, 50.0),
			Gene.new(TEST_TYPE_1, &"size", 1, 75.0),
		]
		var singular_types: Array[StringName] = [SINGULAR_TYPE]

		var removed: int = GA.ensure_singular_types(genome, singular_types)

		assert_eq(removed, 1, "Должен быть удалён только дубликат в singular_types")
		assert_eq(genome.size(), 3, "Должно остаться 3 гена")


class TestFindTypeProperties:
	extends GutTest

	func test_find_type_properties_empty() -> void:
		var genome: Array[Gene] = []
		var result: Array[StringName] = GA.find_type_properties(genome, TEST_TYPE_1)

		assert_eq(result.size(), 0, "Результат должен быть пустым")


	func test_find_type_properties_single_type() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"speed", 0, 50.0),
			Gene.new(TEST_TYPE_1, &"strength", 0, 75.0),
		]
		var result: Array[StringName] = GA.find_type_properties(genome, TEST_TYPE_1)

		assert_eq(result.size(), 3, "Должно быть 3 свойства")
		assert_true(&"health" in result)
		assert_true(&"speed" in result)
		assert_true(&"strength" in result)


	func test_find_type_properties_filtered() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"length", 0, 50.0),
			Gene.new(TEST_TYPE_1, &"speed", 0, 75.0),
		]
		var result: Array[StringName] = GA.find_type_properties(genome, TEST_TYPE_1)

		assert_eq(result.size(), 2, "Должно быть 2 свойства для TEST_TYPE_1")
		assert_true(&"health" in result)
		assert_true(&"speed" in result)


	func test_find_type_properties_duplicates() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"health", 1, 200.0), # то же имя, другой индекс
		]
		var result: Array[StringName] = GA.find_type_properties(genome, TEST_TYPE_1)

		assert_eq(result.size(), 1, "Должно быть только одно уникальное имя")
		assert_true(&"health" in result)


class TestRemoveTypeInstance:
	extends GutTest

	func test_remove_type_instance_from_genes_basic() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"speed", 0, 50.0),
			Gene.new(TEST_TYPE_2, &"length", 0, 30.0),
		]
		var removed: Array[Gene] = GA.remove_type_instance_from_genes(genome, TEST_TYPE_1, 0)

		assert_eq(genome.size() - removed.size(), 2, "Должно быть удалено 2 гена")
		assert_eq(removed.size(), 1, "Должен остаться 1 ген")
		assert_eq(removed[0].type, TEST_TYPE_2)


	func test_remove_type_instance_from_genes_specific_index() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_1, &"speed", 0, 50.0),
		]
		var removed: Array[Gene] = GA.remove_type_instance_from_genes(genome, TEST_TYPE_1, 1)

		assert_eq(genome.size() - removed.size(), 1, "Должен быть удалён 1 ген")
		assert_eq(removed.size(), 2, "Должно остаться 2 гена")
		assert_eq(removed[0].index, 0)
		assert_eq(removed[1].index, 0)


	func test_remove_type_instance_from_genes_nonexistent() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var removed: Array[Gene] = GA.remove_type_instance_from_genes(genome, TEST_TYPE_2, 0)

		assert_eq(removed.size(), genome.size(), "Размер не должен измениться")


class TestAlphaRecombination:
	extends GutTest

	func before_each() -> void:
		seed(42)


	func test_alpha_recombinationf_default_delta() -> void:
		# Тестируем в пределах разумного диапазона
		var param1: float = 10.0
		var param2: float = 20.0
		var result: float = GA.alpha_recombinationf(param1, param2)

		# Результат должен быть между param1 и param2 с учётом delta 0.25
		# То есть alpha может быть от -0.25 до 1.25
		var min_possible: float = param1 - 0.25 * (param2 - param1) # 10 - 2.5 = 7.5
		var max_possible: float = param1 + 1.25 * (param2 - param1) # 10 + 12.5 = 22.5

		assert_between(
			result,
			min_possible,
			max_possible,
			"Результат должен быть в диапазоне [-0.25, 1.25] от интерполяции",
		)


	func test_alpha_recombinationf_custom_delta() -> void:
		var param1: float = 100.0
		var param2: float = 200.0
		var delta: float = 0.5

		var min_possible: float = param1 - 0.5 * (param2 - param1) # 100 - 50 = 50
		var max_possible: float = param1 + 1.5 * (param2 - param1) # 100 + 150 = 250

		# Несколько прогонов для проверки
		for i in range(20):
			var result: float = GA.alpha_recombinationf(param1, param2, delta)
			assert_between(
				result,
				min_possible,
				max_possible,
				"Результат должен быть в диапазоне с delta=0.5",
			)


	func test_alpha_recombinationf_identical_values() -> void:
		var param1: float = 50.0
		var param2: float = 50.0
		var result: float = GA.alpha_recombinationf(param1, param2)

		# Если значения одинаковы, результат всегда должен быть равен им
		assert_eq(result, 50.0, "При одинаковых значениях результат должен быть равен им")


class TestRealValueMutation:
	extends GutTest

	func before_each() -> void:
		seed(42)


	func test_real_value_mutation_basic() -> void:
		var value: float = 100.0
		var val_range: float = 50.0
		var iter: int = 3

		var result: float = GA.real_value_mutation(value, val_range, iter)

		# Проверяем, что мутация не слишком далека от исходного значения
		var max_delta: float = val_range * 0.5 # alpha * calc_delta(max)
		assert_between(
			result,
			value - max_delta,
			value + max_delta,
			"Мутация должна быть в разумных пределах",
		)


	func test_real_value_mutation_iter_1() -> void:
		var value: float = 100.0
		var val_range: float = 100.0
		var iter: int = 1

		var result: float = GA.real_value_mutation(value, val_range, iter)

		# При iter=1, calc_delta может вернуть 0.5 или 0
		var max_delta: float = val_range * 0.5 * 0.5 # alpha = 0.5*val_range, max calc_delta = 0.5
		assert_between(
			result,
			value - max_delta,
			value + max_delta,
			"При iter=1 мутация должна быть ограничена",
		)


class TestRandomCut:
	extends GutTest

	func test_random_cut_basic() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"speed", 0, 50.0),
			Gene.new(TEST_TYPE_2, &"length", 0, 30.0),
			Gene.new(TEST_TYPE_2, &"width", 0, 20.0),
		]
		var exclude_types: Array[StringName] = []

		var removed: Array[Gene] = GA.random_cut(genome, exclude_types)

		assert_gt(genome.size() - removed.size(), 0, "Должно быть удалено хотя бы несколько генов")
		assert_lt(removed.size(), 4, "Размер должен уменьшиться")


	func test_random_cut_empty_genome() -> void:
		var genome: Array[Gene] = []
		var exclude_types: Array[StringName] = []

		var removed: Array[Gene] = GA.random_cut(genome, exclude_types)

		assert_eq(removed.size(), 0, "Для пустого генома должно вернуть 0 элементов")


	func test_random_cut_all_excluded() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"speed", 0, 50.0),
		]
		var exclude_types: Array[StringName] = [TEST_TYPE_1]

		var removed: Array[Gene] = GA.random_cut(genome, exclude_types)

		assert_eq(removed.size(), genome.size(), "Размер не должен измениться")
