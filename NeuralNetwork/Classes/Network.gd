class_name Network
extends RefCounted
# Written by Variable-ind (https://github.com/Variable-ind)

signal activation_changed(layer_idx, activations)

var num_layers: int
var sizes := PackedInt32Array()
var weights: Array[Matrix]  ## an array of weight square matrices
var biases: Array[Matrix]  ## an array of bias column matrices

## Variable for reward based training
var reward: float = 0

var _visualizer: Node


func _init(_sizes: PackedInt32Array) -> void:
	# initializing with random weights and biases
	num_layers = _sizes.size()
	sizes = _sizes
	for layer in range(1, sizes.size()): # 0th layer will have no bias/weights so we start with 1
		var size_x = sizes[layer - 1]  # number of columns (no of neurons in previous layer)
		var size_y = sizes[layer]  # number of rows (no of neurons in current layer)
		biases.append(Matrix.new(size_y, 1, true))
		weights.append(Matrix.new(size_y, size_x, true))


func feedforward(activation_array: Array[float]) -> Array:
	# A failsafe
	if activation_array.size() != sizes[0]:
		printerr("Inputs are not equal to first layer nodes")
		activation_array.resize(sizes[0])
		for i in activation_array.size():
			if activation_array[i] == null:
				activation_array[i] = 0

	# The initial array will be a simple array so we'll convert to a vertical matrix
	var activation_matrix = Matrix.new(activation_array.size(), 1)
	for row in range(activation_matrix.no_of_rows):
		activation_matrix.set_index(row, 0, activation_array[row])

	emit_signal("activation_changed", 0, activation_matrix)

	# activation array is the set of activation numbers of input layer
	for layer in num_layers - 1:
		var b = biases[layer]
		var w = weights[layer]
		# find the activation numbers for the next layer
		activation_matrix = w.dot(activation_matrix).add(b).sigmoid()
		emit_signal("activation_changed", layer + 1, activation_matrix)
	# now the activation array consist of output activation
	return activation_matrix.to_array()


func give_reward(amount: int):
	reward += amount


func add_visualizer(visualizer_parent: Node, color := Color.WHITE):
	if _visualizer:
		print("already has a visualizer added")
		return
	_visualizer = preload("res://NetworkVisualizer/NetworkVisualizer.tscn").instantiate()
	visualizer_parent.add_child(_visualizer)
	_visualizer.identifier.color = color
	_visualizer.visualize_network(self)


func destroy_visualizer():
	if _visualizer:
		_visualizer.queue_free()
