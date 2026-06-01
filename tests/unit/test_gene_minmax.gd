extends GutTest

const NUMERIC := preload("res://etc/numeric.gd")


func test_minmax_init() -> void:
	var minmax := GeneMinMax.new(-10.0, 10.0)
	assert_almost_eq(
		minmax.min_value,
		-10.0,
		NUMERIC.EPS,
		"Минимум должен корректно инициализироваться",
	)
	assert_almost_eq(
		minmax.max_value,
		10.0,
		NUMERIC.EPS,
		"Максимум должен корректно инициализироваться",
	)


func test_incorrect_minmax_init() -> void:
	var minmax := GeneMinMax.new(10.0, -10.0)
	assert_lte(minmax.min_value, minmax.max_value, "Минимум не может быть больше максимума")


func test_minmax_min_setter() -> void:
	var minmax := GeneMinMax.new(-10.0, 10.0)

	minmax.min_value = 5.0
	assert_almost_eq(
		minmax.min_value,
		5.0,
		NUMERIC.EPS,
		"Минимум должен обновиться",
	)

	minmax.min_value = 15.0
	assert_lte(
		minmax.min_value,
		10.0,
		"Минимум не может стать больше максимума",
	)

func test_minmax_max_setter() -> void:
	var minmax := GeneMinMax.new(-10.0, 10.0)

	minmax.max_value = 5.0
	assert_almost_eq(
		minmax.max_value,
		5.0,
		NUMERIC.EPS,
		"Максимум должен обновиться",
	)

	minmax.max_value = -15.0
	assert_gte(
		minmax.max_value,
		-10.0,
		"Максимум не может стать меньше минимума",
	)

func test_minmax_value_ranges() -> void:
	var minmax := GeneMinMax.new(-10.0, 10.0)
	assert_almost_eq(
		minmax.value_range(),
		20.0,
		NUMERIC.EPS
	)

	minmax.max_value = 15.0
	assert_almost_eq(
		minmax.value_range(),
		25.0,
		NUMERIC.EPS,
		"Диапазон значений должен обновиться"
	)

	minmax.min_value = -5.0
	assert_almost_eq(
		minmax.value_range(),
		20.0,
		NUMERIC.EPS,
		"Диапазон значений должен обновиться"
	)
