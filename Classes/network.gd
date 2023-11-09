class_name Network
extends RefCounted
# Written by Variable-ind (https://github.com/Variable-ind)

var num_layers: int
var sizes := PackedInt32Array()
var weights: Array[Matrix]  ## an array of a weight square matrices
var biases: Array[Matrix]  ## an array of a bias column matrices

var reward: float = 0

signal activation_changed(layer_idx, activations)

func _init(_sizes: PackedInt32Array) -> void:
	# initializing with random weights and biases
	num_layers = _sizes.size()
	sizes = _sizes
	for layer in range(1, sizes.size()): # first layer will have no bias/weights
		var size_x = sizes[layer - 1]  # number of columns (no of neurons in previous layer)
		var size_y = sizes[layer]  # number of rows (no of neurons in current layer)
		biases.append(Matrix.new(size_y, 1, true))
		weights.append(Matrix.new(size_y, size_x, true))


func feedforward(activation_array: Array) -> Array:
	# A failsafe
	if activation_array.size() != sizes[0]:
		printerr("Inputs are not equall to first layer nodes")
		activation_array.resize(sizes[0])
		for i in activation_array.size():
			if activation_array[i] == null:
				activation_array[i] = 0

	# The initial array will be a simple array so we'll convert to a vertical matrix
	var activation_matrix = Matrix.new(activation_array.size(), 1)
	for row in range(1, activation_matrix.no_of_rows + 1):
		activation_matrix.set_index(row, 1, activation_array[row - 1])

	emit_signal("activation_changed", 0, activation_array)

	# activation array is the set of activation numbers of input layer
	for layer in num_layers - 1:
		var b = biases[layer]
		var w = weights[layer]
		# find the activation numbers for the next layer
		activation_matrix = (w.dot(activation_matrix).add(b)).sigmoid
		emit_signal("activation_changed", layer + 1, activation_matrix)
	# now the activation array consist of output activation
	return activation_matrix.to_array()
