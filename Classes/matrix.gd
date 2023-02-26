class_name Matrix
extends Reference

var _random := RandomNumberGenerator.new()


func create_vertical(array: Array) -> Array:
	var matrix = []
	for item in array.size():
		matrix.append([array[item]])
	return matrix


func de_construct_vertical(matrix: Array) -> Array:
	var array := []
	for item in matrix.size():
		array.append(matrix[item][0])
	return array


func make_rand_matrix(row: int, col: int) -> Array:
	_random.randomize()
	# rows increase top-down so y
	# columns increase from left to right so x
	var matrix = []
	if row < 1 or col < 1:
		return matrix
	for _y in range(row):
		var r = []
		for _x in range(col):
			var value = _random.randfn()
			r.append(value)
		matrix.append(r)
	return matrix


func zero_matrix(row: int, col: int) -> Array:
	var matrix = []
	if row < 1 or col < 1:
		return matrix
	for _y in range(row):
		var r = []
		for _x in range(col):
			r.append(0)
		matrix.append(r)
	return matrix


# Operators
func dot(a: Array, b: Array) -> Array:
	var matrix = zero_matrix(a.size(), b[0].size())
	for i in range(a.size()):
		for j in range(b[0].size()):
			for k in range(a[0].size()):
				matrix[i][j] = matrix[i][j] + a[i][k] * b[k][j]
	return matrix


func add(a: Array, b: Array) -> Array:
	# this will add 2 (x, 1) matrices
	for i in a.size():
		a[i][0] = a[i][0] + b[i][0]
	return a


func sigmoid(activation_array: Array) -> Array:
	# The sigmoid function.
	for idx in activation_array.size():
		var x = activation_array[idx][0]
		activation_array[idx][0] = 1.0 / (1.0 + exp(-x))
	return activation_array
