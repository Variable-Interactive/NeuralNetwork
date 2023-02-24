class_name Network
extends Reference


var num_layers: int
var sizes := PoolIntArray()
var weights := Array()
var biases := Array()  # an array of a bias column matrices

var random := RandomNumberGenerator.new()

func _init(_sizes: PoolIntArray) -> void:
	# initializing with random weights and biases
	randomize()
	num_layers = _sizes.size()
	sizes = _sizes
	for layer in range(1, sizes.size()): # first layer will have no bias
		var size_x = sizes[layer - 1]  # number of columns (no of neurons in previous layer)
		var size_y = sizes[layer]  # number of rows (no of neurons in current layer)
		biases.append(make_rand_matrix(size_y, 1))
		weights.append(make_rand_matrix(size_y, size_x))


func feedforward(activation_array: Array) -> Array:
	# activation array is the set of activation numbers of input layer
	for layer in num_layers - 1:
		var b = biases[layer]
		var w = weights[layer]
		# find the activation numbers for the next layer
		activation_array = sigmoid(add(dot(w, activation_array), b))
	# now the activation array consist of output activation
	return activation_array


# Misc/Helper Functions
func sigmoid(activation_array: Array):
	# The sigmoid function.
	for idx in activation_array.size():
		var x = activation_array[idx][0]
		activation_array[idx][0] = 1.0 / (1.0 + exp(-x))
	return activation_array


func make_rand_matrix(row: int, col: int) -> Array:
	# rows increase top-down so y
	# columns increase from left to right so x
	var matrix = []
	if row < 1 or col < 1:
		return matrix
	for _y in range(row):
		var r = []
		for _x in range(col):
			r.append(random.randfn())
		matrix.append(r)
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
