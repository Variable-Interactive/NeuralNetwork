class_name Network
extends RefCounted
# Written by Variable-ind (https://github.com/Variable-ind)

signal activation_changed(layer_idx: int, activations: Matrix)

var num_layers: int
var sizes := PackedInt32Array()
var weights: Array[Matrix]  ## an array of weight square matrices
var biases: Array[Matrix]  ## an array of bias column matrices

var _visualizer: Node


func _init(
	_layer_sizes: PackedInt32Array,
	copy_weights: Array[Matrix] = [],
	copy_biases: Array[Matrix] = []
) -> void:
	# initializing with random weights and biases
	num_layers = _layer_sizes.size()
	sizes = _layer_sizes
	if not copy_weights.is_empty() and not copy_weights.is_empty():
		biases = copy_biases.duplicate(true)
		weights = copy_weights.duplicate(true)
		return

	# make a fresh random copy
	for layer in range(1, sizes.size()):  # 0th layer will have no bias/weights so we start with 1
		var row_size = sizes[layer]  # number of rows (no of neurons in current layer)
		var column_size = sizes[layer - 1]  # number of columns (no of neurons in previous layer)
		biases.append(Matrix.new(row_size, 1, true))
		weights.append(Matrix.new(row_size, column_size, true))


func feedforward(inputs: Array[float]) -> Matrix:
	assert(inputs.size() == sizes[0], "Inputs are not equal to first layer nodes")

	## Feeding our inputs to the activation matrix
	var activation_matrix = Matrix.new(inputs.size(), 1)
	for row in range(activation_matrix.no_of_rows):
		activation_matrix.set_index(row, 0, inputs[row])
	emit_signal("activation_changed", 0, activation_matrix)

	## Calculate the next layer's activation array using to the weights and biases
	## the next layer holds for the current layer. (and loop through this procedure till
	## the final layer's activation array is achieved)
	for layer in num_layers - 1:
		var bias = biases[layer]  # Next layer's bias for this layer.
		var weight = weights[layer]  # Next layer's weight for this layer.
		## Find the activation matrix for the next layer
		## N+1 = Sigmoid of {(Weight).(N) + bias}
		activation_matrix = weight.product_matrix(activation_matrix).add(bias).sigmoid()
		emit_signal("activation_changed", layer + 1, activation_matrix)

	## Now the activation array consist of output activation
	return activation_matrix


## Returns a unique clone of the network
func clone() -> Network:
	var new_network: Network = Network.new(sizes, weights, biases)
	return new_network


func add_visualizer(visualizer_parent: Node, color := Color.WHITE):
	if _visualizer:
		print("already has a visualizer added")
		return
	_visualizer = (
		preload("res://addons/NeuralNetwork/NetworkVisualizer/NetworkVisualizer.tscn").instantiate()
	)
	visualizer_parent.add_child(_visualizer)
	_visualizer.identifier.color = color
	_visualizer.visualize_network(self)


func destroy_visualizer():
	if _visualizer:
		_visualizer.queue_free()
