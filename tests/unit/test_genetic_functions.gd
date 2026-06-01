extends GutTest

const GA = preload("res://genetic/genetic_functions.gd")
const NUMERIC = preload("res://etc/numeric.gd")

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


class TestMixGenes:
	extends GutTest

	func before_each() -> void:
		seed(42)


	func test_both_empty() -> void:
		var genome1: Array[Gene] = []
		var genome2: Array[Gene] = []

		var singular_types: Array[StringName] = []
		var exclude_types: Array[StringName] = []

		var probability_curve := Curve.new()
		probability_curve.min_domain = 0.0
		probability_curve.max_domain = 1.0
		var _err := probability_curve.add_point(Vector2(0.0, 0.0))
		_err = probability_curve.add_point(Vector2(1.0, 1.0))

		var d: float = 0.25

		var res: Array[Gene] = GA.mix_genes(
			genome1,
			genome2,
			singular_types,
			exclude_types,
			probability_curve,
			d,
		)

		assert_eq_deep(res, [])
		assert_not_same(res, genome1, "Результат должен быть новым массивом а не ссылкой")
		assert_not_same(res, genome2, "Результат должен быть новым массивом а не ссылкой")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_one_empty() -> void:
		var genome1: Array[Gene] = []
		var genome2: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]

		var singular_types: Array[StringName] = []
		var exclude_types: Array[StringName] = []

		var probability_curve := Curve.new()
		probability_curve.min_domain = 0.0
		probability_curve.max_domain = 1.0
		var _err := probability_curve.add_point(Vector2(0.0, 0.0))
		_err = probability_curve.add_point(Vector2(1.0, 1.0))

		var d: float = 0.25

		var res: Array[Gene] = GA.mix_genes(
			genome1,
			genome2,
			singular_types,
			exclude_types,
			probability_curve,
			d,
		)

		assert_between(res.size(), 0, 1)
		if res.size() == 1:
			assert_eq(res[0].type, TEST_TYPE_1)
			assert_eq(res[0].index, 0)
			assert_eq(res[0].value, 100.0)
			assert_not_same(res[0], genome2[0], "Ген должен быть новым, а не ссылкой на прошлый")
		assert_not_same(res, genome1, "Результат должен быть новым массивом а не ссылкой")
		assert_not_same(res, genome2, "Результат должен быть новым массивом а не ссылкой")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_both_non_empty() -> void:
		var genome1: Array[Gene] = [
			Gene.new(TEST_TYPE_2, &"health", 0, 100.0),
		]
		var genome2: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]

		var singular_types: Array[StringName] = []
		var exclude_types: Array[StringName] = []

		var probability_curve := Curve.new()
		probability_curve.min_domain = 0.0
		probability_curve.max_domain = 1.0
		var _err := probability_curve.add_point(Vector2(0.0, 0.0))
		_err = probability_curve.add_point(Vector2(1.0, 1.0))

		var d: float = 0.25

		var res: Array[Gene] = GA.mix_genes(
			genome1,
			genome2,
			singular_types,
			exclude_types,
			probability_curve,
			d,
		)

		assert_between(res.size(), 0, 2)
		assert_not_same(res, genome1, "Результат должен быть новым массивом а не ссылкой")
		assert_not_same(res, genome2, "Результат должен быть новым массивом а не ссылкой")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_all_excluded() -> void:
		var genome1: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var genome2: Array[Gene] = [
			Gene.new(TEST_TYPE_2, &"health", 0, 100.0),
		]

		var singular_types: Array[StringName] = []
		var exclude_types: Array[StringName] = [TEST_TYPE_1, TEST_TYPE_2]

		var probability_curve := Curve.new()
		probability_curve.min_domain = 0.0
		probability_curve.max_domain = 1.0
		var _err := probability_curve.add_point(Vector2(0.0, 0.0))
		_err = probability_curve.add_point(Vector2(1.0, 1.0))

		var d: float = 0.25

		var res: Array[Gene] = GA.mix_genes(
			genome1,
			genome2,
			singular_types,
			exclude_types,
			probability_curve,
			d,
		)

		assert_eq(res.size(), 2)
		assert_not_same(res, genome1, "Результат должен быть новым массивом а не ссылкой")
		assert_not_same(res, genome2, "Результат должен быть новым массивом а не ссылкой")

		var gene1: Gene
		var gene2: Gene
		for gene: Gene in res:
			if gene.type == TEST_TYPE_1:
				gene1 = gene
			if gene.type == TEST_TYPE_2:
				gene2 = gene

		assert_not_null(gene1)
		assert_not_same(gene1, genome1[0])

		assert_not_null(gene2)
		assert_not_same(gene2, genome1[0])

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_all_singular() -> void:
		var genome1: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var genome2: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]

		var singular_types: Array[StringName] = [TEST_TYPE_1]
		var exclude_types: Array[StringName] = []

		var probability_curve := Curve.new()
		probability_curve.min_domain = 0.0
		probability_curve.max_domain = 1.0
		var _err := probability_curve.add_point(Vector2(0.0, 0.0))
		_err = probability_curve.add_point(Vector2(1.0, 1.0))

		var d: float = 0.25

		var res: Array[Gene] = GA.mix_genes(
			genome1,
			genome2,
			singular_types,
			exclude_types,
			probability_curve,
			d,
		)

		assert_eq(res.size(), 1)
		assert_not_same(res, genome1, "Результат должен быть новым массивом а не ссылкой")
		assert_not_same(res, genome2, "Результат должен быть новым массивом а не ссылкой")

		assert_not_same(res[0], genome1[0])
		assert_not_same(res[0], genome2[0])

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_null_curve() -> void:
		var genome1: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var genome2: Array[Gene] = [
			Gene.new(TEST_TYPE_2, &"health", 0, 100.0),
		]

		var singular_types: Array[StringName] = [TEST_TYPE_1]
		var exclude_types: Array[StringName] = []

		var d: float = 0.25

		var res: Array[Gene] = GA.mix_genes(
			genome1,
			genome2,
			singular_types,
			exclude_types,
			null,
			d,
		)

		assert_between(res.size(), 0, 2)
		assert_not_same(res, genome1, "Результат должен быть новым массивом а не ссылкой")
		assert_not_same(res, genome2, "Результат должен быть новым массивом а не ссылкой")

		assert_push_warning_count(0)
		assert_push_error_count(0)


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


	func test_spliced_gene_is_not_reference() -> void:
		var genome1: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var genome2: Array[Gene] = [
			Gene.new(TEST_TYPE_2, &"speed", 0, 50.0),
		]

		var spliced_genome: Array[Gene] = GA.splice_genes(genome1, genome2)

		genome1[0].type = TEST_TYPE_3
		assert_ne(
			spliced_genome[0].type,
			TEST_TYPE_3,
			"Результирующий геном не привязан к исходным",
		)
		assert_ne(
			spliced_genome[1].type,
			TEST_TYPE_3,
			"Результирующий геном не привязан к исходным",
		)

		genome2[0].value = 200.0
		assert_almost_ne(
			spliced_genome[0].value,
			200.0,
			NUMERIC.EPS,
			"Результирующий геном не привязан к исходным",
		)
		assert_almost_ne(
			spliced_genome[1].value,
			200.0,
			NUMERIC.EPS,
			"Результирующий геном не привязан к исходным",
		)


	func test_splice_genes_changes_indexes() -> void:
		var genome1: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var genome2: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 50.0),
		]
		var result: Array[Gene] = GA.splice_genes(genome1, genome2)

		assert_ne(result[0].index, result[1].index, "Гены не были переиндексированы")


class TestEnsureSingularTypes:
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


class TestRandomCut:
	extends GutTest

	func before_each() -> void:
		seed(42)


	func test_no_exclude() -> void:
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


	func test_empty_genome() -> void:
		var genome: Array[Gene] = []
		var exclude_types: Array[StringName] = []

		var removed: Array[Gene] = GA.random_cut(genome, exclude_types)

		assert_eq(removed.size(), 0, "Для пустого генома должно вернуть 0 элементов")


	func test_all_excluded() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"speed", 0, 50.0),
		]
		var exclude_types: Array[StringName] = [TEST_TYPE_1]

		var removed: Array[Gene] = GA.random_cut(genome, exclude_types)

		assert_eq(removed.size(), genome.size(), "Размер не должен измениться")


	func test_one_type_excluded() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"speed", 0, 50.0),
			Gene.new(TEST_TYPE_2, &"length", 0, 30.0),
		]
		var exclude_types: Array[StringName] = [TEST_TYPE_1]

		var removed: Array[Gene] = GA.random_cut(genome, exclude_types)

		assert_eq(removed.size(), 2, "Тут можно удалить только 1 геном")
		assert_eq(removed[0].type, TEST_TYPE_1, "Должен остаться только тип 1")
		assert_eq(removed[1].type, TEST_TYPE_1, "Должен остаться только тип 1")


	func test_random_cut_is_not_reference() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"speed", 0, 50.0),
			Gene.new(TEST_TYPE_2, &"length", 0, 30.0),
		]
		var exclude_types: Array[StringName] = [TEST_TYPE_1]
		var removed: Array[Gene] = GA.random_cut(genome, exclude_types)

		genome[0].type = TEST_TYPE_3
		assert_ne(removed[0].type, TEST_TYPE_3, "Результирующий массив не должен меняться")
		assert_ne(removed[1].type, TEST_TYPE_3, "Результирующий массив не должен меняться")

		genome[1].value = 200.0
		assert_almost_ne(
			removed[0].value,
			200.0,
			NUMERIC.EPS,
			"Результирующий массив не должен меняться",
		)
		assert_almost_ne(
			removed[1].value,
			200.0,
			NUMERIC.EPS,
			"Результирующий массив не должен меняться",
		)


class TestRemoveTypeInstance:
	extends GutTest

	func test_remove_complex_type() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"speed", 0, 50.0),
			Gene.new(TEST_TYPE_2, &"length", 0, 30.0),
		]
		var removed: Array[Gene] = GA.remove_type_instance_from_genes(genome, TEST_TYPE_1, 0)

		assert_eq(genome.size() - removed.size(), 2, "Должно быть удалено 2 гена")
		assert_eq(removed.size(), 1, "Должен остаться 1 ген")
		assert_eq(removed[0].type, TEST_TYPE_2)


	func test_remove_single_index_from_type() -> void:
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


	func test_remove_nonexsistant_type() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var removed: Array[Gene] = GA.remove_type_instance_from_genes(genome, TEST_TYPE_2, 0)

		assert_eq(removed.size(), genome.size(), "Размер не должен измениться")


	func test_remove_from_empty_genome() -> void:
		var genome: Array[Gene] = []
		var removed: Array[Gene] = GA.remove_type_instance_from_genes(genome, TEST_TYPE_2, 0)

		assert_eq(removed, [], "Результирующий массив должен быть пуст")


	func test_result_is_not_reference() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_1, &"speed", 0, 50.0),
		]
		var removed: Array[Gene] = GA.remove_type_instance_from_genes(genome, TEST_TYPE_1, 1)

		genome[0].index = 1
		assert_ne(removed[0].index, 1, "Результирующий массив не должен поменяться")
		assert_ne(removed[1].index, 1, "Результирующий массив не должен поменяться")

		genome[2].type = TEST_TYPE_3
		assert_ne(removed[0].type, TEST_TYPE_3, "Результирующий массив не должен поменяться")
		assert_ne(removed[1].type, TEST_TYPE_3, "Результирующий массив не должен поменяться")


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


class TestMutateRandomGene:
	extends GutTest

	func before_each() -> void:
		seed(42)


	func test_mutate_empty_genome() -> void:
		var genome: Array[Gene] = []
		var gene_ranges := GeneRanges.new()
		GA.mutate_random_gene(genome, gene_ranges)

		assert_not_null(genome, "Геном не должен пропасть")
		assert_eq_deep(genome, [])

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_mutate_single_gene_genome() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]

		var type_range := TypeRanges.new()
		type_range.ranges_for_type = {
			&"health": GeneMinMax.new(50.0, 150.0),
		}
		var gene_ranges := GeneRanges.new()
		gene_ranges.gene_ranges = {
			TEST_TYPE_1: type_range,
		}

		GA.mutate_random_gene(genome, gene_ranges)

		assert_eq(genome.size(), 1, "Размер генома не должен измениться")
		assert_eq(genome[0].type, TEST_TYPE_1, "Тип гена не должен поменяться")
		assert_eq(genome[0].name, &"health", "Имя гена не должно поменяться")
		assert_eq(genome[0].index, 0, "Индекс гена не должен поменяться")
		assert_ne(genome[0].value, 100.0, "Значение гена должно поменяться")
		assert_between(
			genome[0].value,
			50.0 * 0.85,
			100.0 * 1.25,
			"Значение гена не должно выйти за пределы границ",
		)

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_mutate_multiple_gene_genome() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"size", 0, 50.0),
		]

		var type_range1 := TypeRanges.new()
		type_range1.ranges_for_type = {
			&"health": GeneMinMax.new(50.0, 150.0),
		}
		var type_range2 := TypeRanges.new()
		type_range2.ranges_for_type = {
			&"size": GeneMinMax.new(10.0, 70.0),
		}
		var gene_ranges := GeneRanges.new()
		gene_ranges.gene_ranges = {
			TEST_TYPE_1: type_range1,
			TEST_TYPE_2: type_range2,
		}

		GA.mutate_random_gene(genome, gene_ranges)

		assert_eq(genome.size(), 2, "Размер генома не должен измениться")

		var mutated_gene: Gene = null
		if genome[0].value != 100.0:
			mutated_gene = genome[0]
		if genome[1].value != 50.0:
			mutated_gene = genome[1]

		assert_not_null(mutated_gene, "Один из генов должен был мутировать")

		if mutated_gene == genome[0]:
			# 0-ый изменился
			assert_eq(genome[0].type, TEST_TYPE_1, "Тип гена не должен поменяться")
			assert_eq(genome[0].name, &"health", "Имя гена не должно поменяться")
			assert_eq(genome[0].index, 0, "Индекс гена не должен поменяться")
			assert_between(
				genome[0].value,
				50.0 * 0.85,
				150.0 * 1.25,
				"Значение гена не должно выйти за пределы границ",
			)
			assert_ne(genome[0].value, 50.0, "Значение гена должно было поменяться")

			# 1-ый не изменился
			assert_eq(genome[1].type, TEST_TYPE_2, "Тип гена не должен поменяться")
			assert_eq(genome[1].name, &"size", "Имя гена не должно поменяться")
			assert_eq(genome[1].index, 0, "Индекс гена не должен поменяться")
			assert_eq(genome[1].value, 50.0, "Значение другого гена не должно поменяться")
		else:
			# 0-ый не изменился
			assert_eq(genome[0].type, TEST_TYPE_1, "Тип гена не должен поменяться")
			assert_eq(genome[0].name, &"health", "Имя гена не должно поменяться")
			assert_eq(genome[0].index, 0, "Индекс гена не должен поменяться")
			assert_eq(genome[0].value, 100.0, "Значение другого гена не должно поменяться")

			# 1-ый изменился
			assert_eq(genome[1].type, TEST_TYPE_2, "Тип гена не должен поменяться")
			assert_eq(genome[1].name, &"size", "Имя гена не должно поменяться")
			assert_eq(genome[1].index, 0, "Индекс гена не должен поменяться")
			assert_between(
				genome[1].value,
				10.0 * 0.85,
				70.0 * 1.15,
				"Значение гена не должно выйти за пределы границ",
			)
			assert_ne(genome[1].value, 50.0, "Значение гена должно было поменяться")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_mutate_null_gene_ranges() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]

		GA.mutate_random_gene(genome, null)

		assert_eq(genome.size(), 1, "Размер генома не должен измениться")
		assert_eq(genome[0].type, TEST_TYPE_1, "Тип гена не должен поменяться")
		assert_eq(genome[0].name, &"health", "Имя гена не должно поменяться")
		assert_eq(genome[0].index, 0, "Индекс гена не должен поменяться")
		assert_ne(genome[0].value, 100.0, "Значение гена должно поменяться")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_mutate_empty_gene_ranges() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var gene_ranges := GeneRanges.new()

		GA.mutate_random_gene(genome, gene_ranges)

		assert_eq(genome.size(), 1, "Размер генома не должен измениться")
		assert_eq(genome[0].type, TEST_TYPE_1, "Тип гена не должен поменяться")
		assert_eq(genome[0].name, &"health", "Имя гена не должно поменяться")
		assert_eq(genome[0].index, 0, "Индекс гена не должен поменяться")
		assert_ne(genome[0].value, 100.0, "Значение гена должно поменяться")

		assert_push_warning_count(0)
		assert_push_error_count(0)


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


class TestAddRandomGene:
	extends GutTest

	func before_each() -> void:
		seed(42)


	func test_empty_genome_single_property() -> void:
		var genome: Array[Gene] = []

		var type_ranges := TypeRanges.new()
		type_ranges.ranges_for_type = {
			&"health": GeneMinMax.new(-10.0, 10.0),
		}
		var gene_ranges := GeneRanges.new()
		gene_ranges.gene_ranges = {
			TEST_TYPE_1: type_ranges,
		}

		GA.add_random_gene(genome, gene_ranges, [])

		assert_eq(genome.size(), 1, "Должен добавиться 1 ген")
		assert_eq(genome[0].type, TEST_TYPE_1)
		assert_eq(genome[0].name, &"health")
		assert_eq(genome[0].index, 0)
		assert_between(
			genome[0].value,
			-10.0,
			10.0,
			"Новые значения должны быть в заданых GeneRanges диапазонах",
		)

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_empty_genome_multiple_properties() -> void:
		var genome: Array[Gene] = []

		var type_ranges := TypeRanges.new()
		type_ranges.ranges_for_type = {
			&"health": GeneMinMax.new(-10.0, 10.0),
			&"size": GeneMinMax.new(-20.0, -10.0),
			&"length": GeneMinMax.new(50.0, 150.0),
		}
		var gene_ranges := GeneRanges.new()
		gene_ranges.gene_ranges = {
			TEST_TYPE_1: type_ranges,
		}

		GA.add_random_gene(genome, gene_ranges, [])

		assert_eq(genome.size(), 3, "Должно добавиться 3 гена")

		assert_eq(genome[0].type, TEST_TYPE_1)
		assert_eq(genome[1].type, TEST_TYPE_1)
		assert_eq(genome[2].type, TEST_TYPE_1)

		assert_eq(genome[0].index, 0)
		assert_eq(genome[1].index, 0)
		assert_eq(genome[2].index, 0)

		var health_gene: Gene = null
		for gene: Gene in genome:
			if gene.name == &"health":
				health_gene = gene
		assert_not_null(health_gene, "Должен быть ген с именем health")
		assert_between(
			health_gene.value,
			-10.0,
			10.0,
			"Новые значения должны быть в заданых GeneRanges диапазонах",
		)

		var size_gene: Gene = null
		for gene: Gene in genome:
			if gene.name == &"size":
				size_gene = gene
		assert_not_null(size_gene, "Должен быть ген с именем size")
		assert_between(
			size_gene.value,
			-20.0,
			-10.0,
			"Новые значения должны быть в заданых GeneRanges диапазонах",
		)

		var length_gene: Gene = null
		for gene: Gene in genome:
			if gene.name == &"length":
				length_gene = gene
		assert_not_null(length_gene, "Должен быть ген с именем length")
		assert_between(
			length_gene.value,
			50.0,
			150.0,
			"Новые значения должны быть в заданых GeneRanges диапазонах",
		)

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_other_type_genome_multiple_properties() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_2, &"health", 0, 5.0),
			Gene.new(TEST_TYPE_2, &"size", 0, 55.0),
		]

		var type_ranges := TypeRanges.new()
		type_ranges.ranges_for_type = {
			&"health": GeneMinMax.new(-10.0, 10.0),
			&"size": GeneMinMax.new(-20.0, -10.0),
			&"length": GeneMinMax.new(50.0, 150.0),
		}
		var gene_ranges := GeneRanges.new()
		gene_ranges.gene_ranges = {
			TEST_TYPE_1: type_ranges,
		}

		GA.add_random_gene(genome, gene_ranges, [])

		assert_eq(genome.size(), 5, "Должно добавиться 3 гена")

		assert_eq(genome[0].type, TEST_TYPE_2, "Тип существующих генов не должен меняться")
		assert_eq(genome[1].type, TEST_TYPE_2, "Тип существующих генов не должен меняться")

		assert_eq(genome[0].index, 0, "Индекс существующих генов не должен меняться")
		assert_eq(genome[1].index, 0, "Индекс существующих генов не должен меняться")

		assert_eq(genome[0].name, &"health", "Имя существующих генов не должно меняться")
		assert_eq(genome[1].name, &"size", "Имя существующих генов не должно меняться")

		assert_eq(genome[0].value, 5.0, "Значение существующих генов не должно меняться")
		assert_eq(genome[1].value, 55.0, "Значение существующих генов не должно меняться")

		assert_eq(genome[2].type, TEST_TYPE_1)
		assert_eq(genome[3].type, TEST_TYPE_1)
		assert_eq(genome[4].type, TEST_TYPE_1)

		assert_eq(genome[2].index, 0)
		assert_eq(genome[3].index, 0)
		assert_eq(genome[4].index, 0)

		var health_gene: Gene = null
		for gene: Gene in genome:
			if gene.type == TEST_TYPE_1 and gene.name == &"health":
				health_gene = gene
		assert_not_null(health_gene, "Должен быть ген с именем health")
		assert_between(
			health_gene.value,
			-10.0,
			10.0,
			"Новые значения должны быть в заданых GeneRanges диапазонах",
		)

		var size_gene: Gene = null
		for gene: Gene in genome:
			if gene.type == TEST_TYPE_1 and gene.name == &"size":
				size_gene = gene
		assert_not_null(size_gene, "Должен быть ген с именем size")
		assert_between(
			size_gene.value,
			-20.0,
			-10.0,
			"Новые значения должны быть в заданых GeneRanges диапазонах",
		)

		var length_gene: Gene = null
		for gene: Gene in genome:
			if gene.type == TEST_TYPE_1 and gene.name == &"length":
				length_gene = gene
		assert_not_null(length_gene, "Должен быть ген с именем length")
		assert_between(
			length_gene.value,
			50.0,
			150.0,
			"Новые значения должны быть в заданых GeneRanges диапазонах",
		)

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_same_type_genome_multiple_properties() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 565.0),
			Gene.new(TEST_TYPE_1, &"size", 0, 355.0),
			Gene.new(TEST_TYPE_1, &"length", 0, 255.0),
		]

		var type_ranges := TypeRanges.new()
		type_ranges.ranges_for_type = {
			&"health": GeneMinMax.new(-10.0, 10.0),
			&"size": GeneMinMax.new(-20.0, -10.0),
			&"length": GeneMinMax.new(50.0, 150.0),
		}
		var gene_ranges := GeneRanges.new()
		gene_ranges.gene_ranges = {
			TEST_TYPE_1: type_ranges,
		}

		GA.add_random_gene(genome, gene_ranges, [])

		assert_eq(genome.size(), 6, "Должно добавиться 3 гена")

		assert_eq(genome[0].type, TEST_TYPE_1, "Тип существующих генов не должен меняться")
		assert_eq(genome[1].type, TEST_TYPE_1, "Тип существующих генов не должен меняться")
		assert_eq(genome[2].type, TEST_TYPE_1, "Тип существующих генов не должен меняться")

		assert_eq(genome[0].index, 0, "Индекс существующих генов не должен меняться")
		assert_eq(genome[1].index, 0, "Индекс существующих генов не должен меняться")
		assert_eq(genome[2].index, 0, "Индекс существующих генов не должен меняться")

		assert_eq(genome[0].name, &"health", "Имя существующих генов не должно меняться")
		assert_eq(genome[1].name, &"size", "Имя существующих генов не должно меняться")
		assert_eq(genome[2].name, &"length", "Имя существующих генов не должно меняться")

		assert_eq(genome[0].value, 565.0, "Значение существующих генов не должно меняться")
		assert_eq(genome[1].value, 355.0, "Значение существующих генов не должно меняться")
		assert_eq(genome[2].value, 255.0, "Значение существующих генов не должно меняться")

		assert_eq(genome[3].type, TEST_TYPE_1)
		assert_eq(genome[4].type, TEST_TYPE_1)
		assert_eq(genome[5].type, TEST_TYPE_1)

		assert_eq(genome[3].index, 1, "Должен быть следующий индекс")
		assert_eq(genome[4].index, 1, "Должен быть следующий индекс")
		assert_eq(genome[5].index, 1, "Должен быть следующий индекс")

		var health_gene: Gene = null
		for gene: Gene in genome:
			if gene.index == 1 and gene.name == &"health":
				health_gene = gene
		assert_not_null(health_gene, "Должен быть ген с именем health")
		assert_between(
			health_gene.value,
			-10.0,
			10.0,
			"Новые значения должны быть в заданых GeneRanges диапазонах",
		)

		var size_gene: Gene = null
		for gene: Gene in genome:
			if gene.index == 1 and gene.name == &"size":
				size_gene = gene
		assert_not_null(size_gene, "Должен быть ген с именем size")
		assert_between(
			size_gene.value,
			-20.0,
			-10.0,
			"Новые значения должны быть в заданых GeneRanges диапазонах",
		)

		var length_gene: Gene = null
		for gene: Gene in genome:
			if gene.index == 1 and gene.name == &"length":
				length_gene = gene
		assert_not_null(length_gene, "Должен быть ген с именем length")
		assert_between(
			length_gene.value,
			50.0,
			150.0,
			"Новые значения должны быть в заданых GeneRanges диапазонах",
		)

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_multiple_properties_with_excluded_type() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_2, &"health", 0, 5.0),
			Gene.new(TEST_TYPE_2, &"size", 0, 55.0),
		]

		var type_ranges1 := TypeRanges.new()
		type_ranges1.ranges_for_type = {
			&"health": GeneMinMax.new(-10.0, 10.0),
			&"size": GeneMinMax.new(-20.0, -10.0),
			&"length": GeneMinMax.new(50.0, 150.0),
		}
		var type_ranges2 := TypeRanges.new()
		type_ranges2.ranges_for_type = {
			&"width": GeneMinMax.new(-10.0, 10.0),
			&"speed": GeneMinMax.new(-20.0, -10.0),
		}
		var gene_ranges := GeneRanges.new()
		gene_ranges.gene_ranges = {
			TEST_TYPE_1: type_ranges1,
			TEST_TYPE_3: type_ranges2,
		}

		GA.add_random_gene(genome, gene_ranges, [TEST_TYPE_3])

		assert_eq(genome.size(), 5, "Должно добавиться 3 гена")

		for gene: Gene in genome:
			assert_ne(gene.type, TEST_TYPE_3, "Тип 3 не должен появиться, так как исключён")

		assert_eq(genome[0].type, TEST_TYPE_2, "Тип существующих генов не должен меняться")
		assert_eq(genome[1].type, TEST_TYPE_2, "Тип существующих генов не должен меняться")

		assert_eq(genome[0].index, 0, "Индекс существующих генов не должен меняться")
		assert_eq(genome[1].index, 0, "Индекс существующих генов не должен меняться")

		assert_eq(genome[0].name, &"health", "Имя существующих генов не должно меняться")
		assert_eq(genome[1].name, &"size", "Имя существующих генов не должно меняться")

		assert_eq(genome[0].value, 5.0, "Значение существующих генов не должно меняться")
		assert_eq(genome[1].value, 55.0, "Значение существующих генов не должно меняться")

		assert_eq(genome[2].type, TEST_TYPE_1)
		assert_eq(genome[3].type, TEST_TYPE_1)
		assert_eq(genome[4].type, TEST_TYPE_1)

		assert_eq(genome[2].index, 0)
		assert_eq(genome[3].index, 0)
		assert_eq(genome[4].index, 0)

		var health_gene: Gene = null
		for gene: Gene in genome:
			if gene.type == TEST_TYPE_1 and gene.name == &"health":
				health_gene = gene
		assert_not_null(health_gene, "Должен быть ген с именем health")
		assert_between(
			health_gene.value,
			-10.0,
			10.0,
			"Новые значения должны быть в заданых GeneRanges диапазонах",
		)

		var size_gene: Gene = null
		for gene: Gene in genome:
			if gene.type == TEST_TYPE_1 and gene.name == &"size":
				size_gene = gene
		assert_not_null(size_gene, "Должен быть ген с именем size")
		assert_between(
			size_gene.value,
			-20.0,
			-10.0,
			"Новые значения должны быть в заданых GeneRanges диапазонах",
		)

		var length_gene: Gene = null
		for gene: Gene in genome:
			if gene.type == TEST_TYPE_1 and gene.name == &"length":
				length_gene = gene
		assert_not_null(length_gene, "Должен быть ген с именем length")
		assert_between(
			length_gene.value,
			50.0,
			150.0,
			"Новые значения должны быть в заданых GeneRanges диапазонах",
		)

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_multiple_properties_with_excluded_type2() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_2, &"health", 0, 5.0),
			Gene.new(TEST_TYPE_2, &"size", 0, 55.0),
		]

		var type_ranges1 := TypeRanges.new()
		type_ranges1.ranges_for_type = {
			&"health": GeneMinMax.new(-10.0, 10.0),
			&"size": GeneMinMax.new(-20.0, -10.0),
			&"length": GeneMinMax.new(50.0, 150.0),
		}
		var type_ranges2 := TypeRanges.new()
		type_ranges2.ranges_for_type = {
			&"width": GeneMinMax.new(-10.0, 10.0),
			&"speed": GeneMinMax.new(-20.0, -10.0),
		}
		var gene_ranges := GeneRanges.new()
		gene_ranges.gene_ranges = {
			TEST_TYPE_1: type_ranges1,
			TEST_TYPE_2: type_ranges2,
		}

		GA.add_random_gene(genome, gene_ranges, [TEST_TYPE_2])

		assert_eq(genome.size(), 5, "Должно добавиться 3 гена")

		assert_eq(genome[0].type, TEST_TYPE_2, "Тип существующих генов не должен меняться")
		assert_eq(genome[1].type, TEST_TYPE_2, "Тип существующих генов не должен меняться")

		assert_eq(genome[0].index, 0, "Индекс существующих генов не должен меняться")
		assert_eq(genome[1].index, 0, "Индекс существующих генов не должен меняться")

		assert_eq(genome[0].name, &"health", "Имя существующих генов не должно меняться")
		assert_eq(genome[1].name, &"size", "Имя существующих генов не должно меняться")

		assert_eq(genome[0].value, 5.0, "Значение существующих генов не должно меняться")
		assert_eq(genome[1].value, 55.0, "Значение существующих генов не должно меняться")

		assert_eq(genome[2].type, TEST_TYPE_1)
		assert_eq(genome[3].type, TEST_TYPE_1)
		assert_eq(genome[4].type, TEST_TYPE_1)

		assert_eq(genome[2].index, 0)
		assert_eq(genome[3].index, 0)
		assert_eq(genome[4].index, 0)

		var health_gene: Gene = null
		for gene: Gene in genome:
			if gene.type == TEST_TYPE_1 and gene.name == &"health":
				health_gene = gene
		assert_not_null(health_gene, "Должен быть ген с именем health")
		assert_between(
			health_gene.value,
			-10.0,
			10.0,
			"Новые значения должны быть в заданых GeneRanges диапазонах",
		)

		var size_gene: Gene = null
		for gene: Gene in genome:
			if gene.type == TEST_TYPE_1 and gene.name == &"size":
				size_gene = gene
		assert_not_null(size_gene, "Должен быть ген с именем size")
		assert_between(
			size_gene.value,
			-20.0,
			-10.0,
			"Новые значения должны быть в заданых GeneRanges диапазонах",
		)

		var length_gene: Gene = null
		for gene: Gene in genome:
			if gene.type == TEST_TYPE_1 and gene.name == &"length":
				length_gene = gene
		assert_not_null(length_gene, "Должен быть ген с именем length")
		assert_between(
			length_gene.value,
			50.0,
			150.0,
			"Новые значения должны быть в заданых GeneRanges диапазонах",
		)

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_all_types_excluded() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_2, &"health", 0, 5.0),
			Gene.new(TEST_TYPE_2, &"size", 0, 55.0),
		]

		var type_ranges1 := TypeRanges.new()
		type_ranges1.ranges_for_type = {
			&"health": GeneMinMax.new(-10.0, 10.0),
			&"size": GeneMinMax.new(-20.0, -10.0),
			&"length": GeneMinMax.new(50.0, 150.0),
		}
		var type_ranges2 := TypeRanges.new()
		type_ranges2.ranges_for_type = {
			&"width": GeneMinMax.new(-10.0, 10.0),
			&"speed": GeneMinMax.new(-20.0, -10.0),
		}
		var gene_ranges := GeneRanges.new()
		gene_ranges.gene_ranges = {
			TEST_TYPE_1: type_ranges1,
			TEST_TYPE_3: type_ranges2,
		}

		GA.add_random_gene(genome, gene_ranges, [TEST_TYPE_1, TEST_TYPE_3])

		assert_eq(genome.size(), 2, "Размер не должен измениться")

		assert_eq(genome[0].type, TEST_TYPE_2, "Тип существующих генов не должен меняться")
		assert_eq(genome[1].type, TEST_TYPE_2, "Тип существующих генов не должен меняться")

		assert_eq(genome[0].index, 0, "Индекс существующих генов не должен меняться")
		assert_eq(genome[1].index, 0, "Индекс существующих генов не должен меняться")

		assert_eq(genome[0].name, &"health", "Имя существующих генов не должно меняться")
		assert_eq(genome[1].name, &"size", "Имя существующих генов не должно меняться")

		assert_eq(genome[0].value, 5.0, "Значение существующих генов не должно меняться")
		assert_eq(genome[1].value, 55.0, "Значение существующих генов не должно меняться")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_empty_gene_ranges() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_2, &"health", 0, 5.0),
			Gene.new(TEST_TYPE_2, &"size", 0, 55.0),
		]

		GA.add_random_gene(genome, GeneRanges.new(), [])

		assert_eq(genome.size(), 2, "Размер не должен измениться")

		assert_eq(genome[0].type, TEST_TYPE_2, "Тип существующих генов не должен меняться")
		assert_eq(genome[1].type, TEST_TYPE_2, "Тип существующих генов не должен меняться")

		assert_eq(genome[0].index, 0, "Индекс существующих генов не должен меняться")
		assert_eq(genome[1].index, 0, "Индекс существующих генов не должен меняться")

		assert_eq(genome[0].name, &"health", "Имя существующих генов не должно меняться")
		assert_eq(genome[1].name, &"size", "Имя существующих генов не должно меняться")

		assert_eq(genome[0].value, 5.0, "Значение существующих генов не должно меняться")
		assert_eq(genome[1].value, 55.0, "Значение существующих генов не должно меняться")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_null_gene_ranges() -> void:
		var genome: Array[Gene] = [
			Gene.new(TEST_TYPE_2, &"health", 0, 5.0),
			Gene.new(TEST_TYPE_2, &"size", 0, 55.0),
		]

		GA.add_random_gene(genome, null, [])

		assert_eq(genome.size(), 2, "Размер не должен измениться")

		assert_eq(genome[0].type, TEST_TYPE_2, "Тип существующих генов не должен меняться")
		assert_eq(genome[1].type, TEST_TYPE_2, "Тип существующих генов не должен меняться")

		assert_eq(genome[0].index, 0, "Индекс существующих генов не должен меняться")
		assert_eq(genome[1].index, 0, "Индекс существующих генов не должен меняться")

		assert_eq(genome[0].name, &"health", "Имя существующих генов не должно меняться")
		assert_eq(genome[1].name, &"size", "Имя существующих генов не должно меняться")

		assert_eq(genome[0].value, 5.0, "Значение существующих генов не должно меняться")
		assert_eq(genome[1].value, 55.0, "Значение существующих генов не должно меняться")

		assert_push_warning_count(0)
		assert_push_error_count(0)
