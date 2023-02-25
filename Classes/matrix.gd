class_name Matrix
extends Reference

var random := RandomNumberGenerator.new()
var spread := 5

# Misc/Helper Functions
func sigmoid(activation_array: Array):
	# The sigmoid function.
	for idx in activation_array.size():
		var x = activation_array[idx][0]
		activation_array[idx][0] = 1.0 / (1.0 + exp(-x))
	return activation_array


func make_rand_matrix(row: int, col: int) -> Array:
	random.randomize()
	# rows increase top-down so y
	# columns increase from left to right so x
	var matrix = []
	if row < 1 or col < 1:
		return matrix
	for _y in range(row):
		var r = []
		for _x in range(col):
			var value = random.randfn() * spread
			r.append(value)
		matrix.append(r)
	return matrix


func mutate_matrix(matrix: Array, threshold: float):
	var a := []
	random.randomize()
	# rows increase top-down so y
	# columns increase from left to right so x
	for y in matrix.size():
		for x in range(matrix[y].size()):
			var value = random.randf()
			a.append(value)
			if value < threshold:
				matrix[y][x] = random.randfn() * spread
	return matrix


func dot(a: Array, b: Array) -> Array:
	var matrix = zero_matrix(a.size(), b[0].size())
	for i in range(a.size()):
		for j in range(b[0].size()):
			for k in range(a[0].size()):
				matrix[i][j] = matrix[i][j] + a[i][k] * b[k][j]
	return matrix


func add(a: Array, b: Array):
	# this will add 2 (x, 1) matrices
	for i in a.size():
		a[i][0] = a[i][0] + b[i][0]
	return a


func zero_matrix(row: int, col: int):
	var matrix = []
	if row < 1 or col < 1:
		return matrix
	for _y in range(row):
		var r = []
		for _x in range(col):
			r.append(0)
		matrix.append(r)
	return matrix
