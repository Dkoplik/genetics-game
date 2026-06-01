extends GutTest

const NUMERIC := preload("res://etc/numeric.gd")


func test_gene_ranges_init() -> void:
	var gene_ranges := GeneRanges.new()
	assert_eq_deep(gene_ranges.gene_ranges, { })


func test_gene_ranges_has_gene() -> void:
	var gene_ranges := GeneRanges.new()
	var type_ranges := TypeRanges.new()
	type_ranges.ranges_for_type = {
		&"health": GeneMinMax.new(-10.0, 10.0),
	}
	gene_ranges.gene_ranges[&"type1"] = type_ranges

	assert_true(gene_ranges.has_gene(&"type1", &"health"))
	assert_false(gene_ranges.has_gene(&"type1", &"size"))
	assert_false(gene_ranges.has_gene(&"type2", &"health"))
	assert_false(gene_ranges.has_gene(&"type2", &"size"))


func test_gene_ranges_get_minmax() -> void:
	var gene_ranges := GeneRanges.new()
	var type_ranges := TypeRanges.new()
	type_ranges.ranges_for_type = {
		&"health": GeneMinMax.new(-10.0, 10.0),
	}
	gene_ranges.gene_ranges[&"type1"] = type_ranges

	var minmax: GeneMinMax = gene_ranges.get_gene_minmax(&"type1", &"health")
	assert_not_null(minmax)
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

	assert_null(gene_ranges.get_gene_minmax(&"type1", &"size"))
	assert_null(gene_ranges.get_gene_minmax(&"type2", &"heatlh"))
	assert_null(gene_ranges.get_gene_minmax(&"type2", &"size"))
