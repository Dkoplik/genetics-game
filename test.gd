extends Node2D


func _ready() -> void:
	var d = {}

	for i in range(-10, 10):
		d.set('key{0}'.format([i]), i)

	for val in d.values():
		print(val)
	print('---')


func bytes_to_binary(bytes: PackedByteArray) -> String:
	var res := ""
	for byte in bytes:
		for i in range(8):
			res += str(Numeric.get_bit_from_int(byte, i))
		res += " "
	return res
