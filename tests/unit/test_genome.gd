extends GutTest


class TestInitAndGetAllParams:
	extends GutTest

	func test_init_with_array_of_int_and_float() -> void:
		var params = [42, 3.14, -100, 0.0]
		var genome = Genome.new(params)
		assert_eq(genome.param_array_size(), params.size())
		assert_eq_deep(genome.get_param_array(), params)
		var keys = genome.get_param_dict().keys()
		assert_eq(keys.size(), params.size())
		for i in range(keys.size()):
			assert_eq(keys[i], "param_{0}".format([i]))
		for i in range(genome.param_array_size()):
			assert_eq(typeof(genome.get_param(i)), typeof(params[i]))
			if params[i] is int:
				assert_eq(genome.get_param(i), params[i])
			else:
				assert_almost_eq(genome.get_param(i), params[i], Numeric.EPS)

	func test_init_with_dictionary() -> void:
		var params = {"a": 123, "b": 456.789}
		var genome = Genome.new(params)
		assert_eq(genome.param_array_size(), params.size())
		assert_eq_deep(genome.get_param_array(), [123, 456.789])
		assert_eq_deep(genome.get_param_dict().keys(), ["a", "b"])
		for i in params.keys():
			assert_eq(typeof(genome.get_param(i)), typeof(params[i]))
			if params[i] is int:
				assert_eq(genome.get_param(i), params[i])
			else:
				assert_almost_eq(genome.get_param(i), params[i], Numeric.EPS)


class TestSetGetParam:
	extends GutTest

	func test_set_get_param_by_index() -> void:
		var genome = Genome.new([100, 200.5])
		genome.set_param(0, 50)
		assert_eq(genome.get_param(0), 50)
		genome.set_param(1, 300.75)
		assert_almost_eq(genome.get_param(1), 300.75, Numeric.EPS)

	func test_set_get_param_by_string_key() -> void:
		var genome = Genome.new({"x": 10, "y": 20.5})
		genome.set_param("x", 20)
		assert_eq(genome.get_param("x"), 20)
		genome.set_param("y", 30.5)
		assert_almost_eq(genome.get_param("y"), 30.5, Numeric.EPS)

	func test_negative_index() -> void:
		var genome = Genome.new([10, 20.5])
		assert_eq(genome.get_param(-1), 20.5)
		genome.set_param(-1, 30.5)
		assert_almost_eq(genome.get_param(1), 30.5, Numeric.EPS)


class TestByteOperations:
	extends GutTest

	func test_int_byte_manipulation() -> void:
		# INT: 0x12345678 (little-endian bytes: 0x78, 0x56, 0x34, 0x12, 0x00, 0x00, 0x00, 0x00)
		var genome = Genome.new([0x12345678])
		assert_eq(genome.get_byte(0), 0x78)
		assert_eq(genome.get_byte(3), 0x12)
		genome.set_byte(3, 0xAB)
		assert_eq(genome.get_param(0), 0xAB345678)

	func test_float_byte_manipulation() -> void:
		# FLOAT: 1.0 (little-endian bytes: 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0x3F)
		var genome = Genome.new([1.0])
		genome.set_byte(7, 0x40)
		assert_almost_eq(genome.get_param(0), 65536.0, Numeric.EPS)

	func test_negative_byte_index() -> void:
		var genome = Genome.new([0x1234])
		genome.set_byte(-1, 0x12)  # 7-ой байт
		assert_eq(genome.get_byte(7), 0x12)
		assert_eq(genome.get_param(0), 0x1200000000001234)

	func test_int_min_max_byte_manipulation() -> void:
		var genome = Genome.new([Numeric.INT_MIN])
		assert_eq(genome.get_byte(7), 0x80)  # Знаковый байт для INT_MIN
		genome.set_byte(7, 0)
		assert_eq(genome.get_param(0), 0)

		genome = Genome.new([Numeric.INT_MAX])
		assert_eq(genome.get_byte(7), 0x7F)  # Знаковый байт для INT_MAX
		genome.set_byte(0, 0xFE)
		assert_eq(genome.get_param(0), Numeric.INT_MAX - 1)


class TestBitOperations:
	extends GutTest

	func test_int_sign_bit_flip() -> void:
		var genome = Genome.new([42])
		genome.set_bit(63, 1)  # Знаковый бит
		assert_eq(genome.get_param(0), Numeric.INT_MIN + 42)

	func test_float_sign_bit_flip() -> void:
		var genome = Genome.new([3.14])
		genome.set_bit(63, 1)  # Знаковый бит
		assert_almost_eq(genome.get_param(0), -3.14, Numeric.EPS)

	func test_bit_manipulation_middle_bits() -> void:
		# INT: 0x00 set bit 3 to 1 → 0x08 (00001000)
		var genome = Genome.new([0])
		genome.set_bit(3, 1)
		assert_eq(genome.get_param(0), 8)


class TestArrayConversions:
	extends GutTest

	func test_byte_array_roundtrip() -> void:
		var original = Genome.new([123456789, 3.1415926535, -42, 0.0])
		var byte_array = original.get_byte_array()
		var new_genome = Genome.new([0, 0.0, 0, 0.0])
		new_genome.set_byte_array(byte_array)
		assert_eq_deep(new_genome.get_param_array(), original.get_param_array())

	func test_param_array_roundtrip() -> void:
		var original = [987654321, 2.71828, -123, 1.414]
		var genome = Genome.new(original)
		var new_genome = Genome.new([0, 0.0, 0, 0.0])
		new_genome.set_param_array(genome.get_param_array())
		assert_eq_deep(new_genome.get_param_array(), original)


class TestSlices:
	extends GutTest

	func test_param_slice() -> void:
		var genome = Genome.new([10, 20.5, 30, 40.5])
		assert_eq_deep(genome.get_param_slice(1, 3), [20.5, 30])

	func test_byte_slice() -> void:
		var genome = Genome.new([0x12345678])
		assert_eq_deep(genome.get_byte_slice(0, 4), PackedByteArray([0x78, 0x56, 0x34, 0x12]))

	func test_bit_slice() -> void:
		var genome = Genome.new([0x0A])
		assert_eq_deep(genome.get_bit_slice(0, 8), [0, 1, 0, 1, 0, 0, 0, 0])


class TestSizeMethods:
	extends GutTest

	func test_sizes() -> void:
		var genome = Genome.new([1, 2.0, 3, 4.0])
		assert_eq(genome.param_array_size(), 4)
		assert_eq(genome.byte_array_size(), 32)  # 4 params * 8 bytes
		assert_eq(genome.bit_array_size(), 256)  # 32 bytes * 8 bits
