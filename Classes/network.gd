class_name Network
extends Reference

var matrix := Matrix.new()

var num_layers: int
var sizes := PoolIntArray()
var weights := Array()
var biases := Array()  # an array of a bias column matrices

var reward: float = 0


func _init(_sizes: PoolIntArray) -> void:
	# initializing with random weights and biases
	num_layers = _sizes.size()
	sizes = _sizes
	for layer in range(1, sizes.size()): # first layer will have no bias
		var size_x = sizes[layer - 1]  # number of columns (no of neurons in previous layer)
		var size_y = sizes[layer]  # number of rows (no of neurons in current layer)
		biases.append(matrix.make_rand_matrix(size_y, 1))
		weights.append(matrix.make_rand_matrix(size_y, size_x))


func feedforward(activation_array: Array) -> Array:
	# activation array is the set of activation numbers of input layer
	for layer in num_layers - 1:
		var b = biases[layer]
		var w = weights[layer]
		# find the activation numbers for the next layer
		activation_array = matrix.sigmoid(matrix.add(matrix.dot(w, activation_array), b))
	# now the activation array consist of output activation
	return activation_array
