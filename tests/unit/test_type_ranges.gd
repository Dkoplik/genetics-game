extends GutTest

const NUMERIC := preload("res://etc/numeric.gd")


func test_type_ranges_init() -> void:
	var type_ranges := TypeRanges.new()
	assert_eq_deep(type_ranges.ranges_for_type, { })


func test_type_ranges_has() -> void:
	var type_ranges := TypeRanges.new()
	type_ranges.ranges_for_type = {
		&"health": GeneMinMax.new(-10.0, 10.0),
	}

	assert_true(type_ranges.has(&"health"), "Должен содержать health")
	assert_false(type_ranges.has(&"size"), "Не содержит несуществующий тип")


func test_type_ranges_get_minmax() -> void:
	var type_ranges := TypeRanges.new()
	type_ranges.ranges_for_type = {
		&"health": GeneMinMax.new(-10.0, 10.0),
	}

	var minmax: GeneMinMax = type_ranges.get_minmax(&"health")
	assert_almost_eq(
		minmax.min_value,
		-10.0,
		NUMERIC.EPS,
	)
	assert_almost_eq(
		minmax.max_value,
		10.0,
		NUMERIC.EPS,
	)
	assert_null(type_ranges.get_minmax(&"size"))
