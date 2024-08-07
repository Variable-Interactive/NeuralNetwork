class_name Network
extends RefCounted
# Written by Variable-ind (https://github.com/Variable-ind)
# Heavily inspired by https://github.com/mnielsen/neural-networks-and-deep-learning/blob/master/src/network.py

signal activation_changed(layer_idx: int, activations: Matrix)

var num_layers: int:
	get:
		return layer_sizes.size()

var weights: Array[Matrix]  ## an array of weight square matrices
var biases: Array[Matrix]  ## an array of bias column matrices

var layer_sizes := PackedInt32Array()
var _visualizer: Node


func _init(
	_sizes: PackedInt32Array,
	copy_weights: Array[Matrix] = [],
	copy_biases: Array[Matrix] = []
) -> void:
	# initializing with random weights and biases
	randomize()
	layer_sizes = _sizes
	if not copy_weights.is_empty() and not copy_weights.is_empty():
		biases = copy_biases.duplicate(true)
		weights = copy_weights.duplicate(true)
		return

	# Make a fresh random copy
	# NOTE: 0th layer will have no bias/weights so we start with 1
	for layer in range(1, layer_sizes.size()):
		# number of rows (no of neurons in current layer)
		var row_size = layer_sizes[layer]
		# number of columns (no of neurons in previous layer)
		var column_size = layer_sizes[layer - 1]
		biases.append(Matrix.new(row_size, 1, true))
		weights.append(Matrix.new(row_size, column_size, true))


func feedforward(inputs: Array[float]) -> Matrix:
	assert(inputs.size() == layer_sizes[0], "Inputs are not equal to first layer nodes")

	## Feeding our inputs to the activation matrix
	var activation_matrix = Matrix.new(inputs.size(), 1)
	for row in range(activation_matrix.no_of_rows):
		activation_matrix.set_index(row, 0, clamp(inputs[row], -1, 1))
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


## Train the neural network using mini-batch stochastic
## gradient descent.  The training_data is an Array of Arrays
## [data, expected output] representing the training inputs and the desired
## outputs.  The other non-optional parameters are
## self-explanatory.  If test_data is provided then the
## network will be evaluated against the test data after each
## epoch, and partial progress printed out.  This is useful for
## tracking progress, but slows things down substantially."""
func SGD(
	training_data: Array[Array],
	epochs: int,
	mini_batch_size: int,
	eta: float,
	test_data: Array[Array] = []
):
	var n = training_data.size()
	for j in range(epochs):
		training_data.shuffle()
		for k in range(0, n, mini_batch_size):
			var mini_batch: Array[Array] = training_data.slice(k, k + mini_batch_size)
			update_mini_batch(mini_batch, eta)
		if test_data:
			print("Epoch %s: %s / %s" % [str(j), str(evaluate(test_data)), str(test_data.size())])
		else:
			print("Epoch %s complete" % str(j))

	if _visualizer:
		_visualizer.update_weights(self)


## Update the network's weights and biases by applying
## gradient descent using backpropagation to a single mini batch.
## The mini_batch is  is an Array of Arrays [data, expected output], and eta
## is the learning rate.
func update_mini_batch(mini_batch: Array[Array], eta: float) -> void:
	var total_nabla_b: Array[Matrix]
	var total_nabla_w: Array[Matrix]
	for i: int in biases.size():
		total_nabla_b.append(Matrix.new(biases[i].no_of_rows, biases[i].no_of_columns))
		total_nabla_w.append(Matrix.new(weights[i].no_of_rows, weights[i].no_of_columns))

	for activation_and_results: Array[Matrix] in mini_batch:
		var error_array = backprop(activation_and_results[0], activation_and_results[1])
		var delta_nabla_b: Array[Matrix] = error_array[0]
		var delta_nabla_w: Array[Matrix] = error_array[1]

		for i: int in total_nabla_b.size():
			total_nabla_b[i] = total_nabla_b[i].add(delta_nabla_b[i])
			total_nabla_w[i] = total_nabla_w[i].add(delta_nabla_w[i])

	# update weights and biases accordinly
	for i: int in weights.size():
		weights[i] = total_nabla_w[i].multiply_scalar(eta / mini_batch.size()).subtract_from(weights[i])
		biases[i] = total_nabla_b[i].multiply_scalar(eta /  mini_batch.size()).subtract_from(biases[i])


## Return an Array [nabla_b, nabla_w] representing the gradient for the cost function C_x.
## nabla_b and nabla_w are layer-by-layer matrices, similar to biases and weights.
func backprop(x: Matrix, y: Matrix):
	var nabla_b_array: Array[Matrix]
	var nabla_w_array: Array[Matrix]
	for i: int in biases.size():
		nabla_b_array.append(Matrix.new(biases[i].no_of_rows, biases[i].no_of_columns))
		nabla_w_array.append(Matrix.new(weights[i].no_of_rows, weights[i].no_of_columns))

	# feedforward
	var activation_matrix: Matrix = x
	var activations: Array[Matrix] = [x] # list to store all the activations, layer by layer
	var zs: Array[Matrix] = [] # list to store all the z vectors, layer by layer
	## Calculate the next layer's activation array using to the weights and biases
	## the next layer holds for the current layer. (and loop through this procedure till
	## the final layer's activation array is achieved)
	for layer in num_layers - 1:
		var bias = biases[layer]  # Next layer's bias for this layer.
		var weight = weights[layer]  # Next layer's weight for this layer.
		## Find the activation matrix for the next layer
		## N+1 = Sigmoid of {(Weight).(N) + bias}
		var z = weight.product_matrix(activation_matrix).add(bias)
		zs.append(z)
		activation_matrix = z.sigmoid()
		activations.append(activation_matrix)

	# backward pass
	var delta := cost_derivative(activations[-1], y).multiply_corresponding(zs[-1].sigmoid_prime())
	nabla_b_array[-1] = delta
	nabla_w_array[-1] = delta.product_matrix(activations[-2].clone(true))
	for l in range(2, num_layers):
		var z := zs[-l]
		var sp = z.sigmoid_prime()
		delta = weights[-l + 1].clone(true).product_matrix(delta).multiply_corresponding(sp)
		nabla_b_array[-l] = delta
		nabla_w_array[-l] = delta.product_matrix(activations[-l-1].clone(true))
	return [nabla_b_array, nabla_w_array]


## Return the number of test inputs for which the neural network outputs the correct result.
## Note that the neural network's output is assumed to be the index of whichever neuron in the
## final layer has the highest activation.
func evaluate(test_data: Array[Array]) -> int:
	var test_results: Array[Array] = []
	var sum: int = 0
	for sample: Array[Matrix] in test_data:
		test_results.append([feedforward(sample[0].to_array()).argmax(), sample[1].argmax()])
	for result: Array[float] in test_results:
		sum += int(result[0] == result[1])
	return sum


## Return the vector of partial derivatives
## (partial C_x / partial a) for the output activations.
func cost_derivative(output_activations: Matrix, y: Matrix) -> Matrix:
	return y.subtract_from(output_activations)


## Returns a unique clone of the network
func clone() -> Network:
	var new_network: Network = Network.new(layer_sizes, weights, biases)
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
