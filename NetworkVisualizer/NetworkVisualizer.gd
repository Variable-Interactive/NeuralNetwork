extends PanelContainer

const SCALE = 1

const LINE_COLOR_POSITIVE = Color.ORANGE_RED
const LINE_COLOR_NEGATIVE = Color.BLUE_VIOLET

const ACTIVATION_COLOR_POSITIVE = Color.WHITE
const ACTIVATION_COLOR_INACTIVE = Color.BLACK
const ACTIVATION_COLOR_NEGATIVE = Color.BLUE  # would appear in 1st layer

var lines = []

@onready var layer_container = $"%LayerContainer"
@onready var identifier: ColorRect = $"%identifier"


func visualize_network(network: Network) -> void:
	# generate a framework
	var sep = 0
	for i in network.sizes:
		if i > sep:
			sep = i
	layer_container.set("theme_override_constants/separation", max(10, sep * 2))
	for x in network.sizes.size():
		var layer = _generate_layer()
		for _y in range(network.sizes[x]):
			_generate_node(layer)
	# now set weights
	await get_tree().process_frame
	update_weights(network)
	# warning-ignore:return_value_discarded
	network.connect("activation_changed", Callable(self, "_update_activations"))


func update_weights(network: Network):
	if visible:
		lines.clear()
		for layer_number in network.weights.size():
			for current_node_idx in range(network.weights[layer_number].no_of_rows):
				for prev_node_idx in range(network.weights[layer_number].no_of_columns):
					var from_node = _get_activation_node(layer_number, prev_node_idx)
					var to_node = _get_activation_node(layer_number + 1, current_node_idx)
					var weight = network.weights[layer_number].get_index(current_node_idx, prev_node_idx)
					lines.append([from_node, to_node, weight])
		queue_redraw()


func _get_activation_node(layer_idx, node_idx) -> TextureRect:
	var layer = layer_container.get_child(layer_idx)
	return layer.get_child(node_idx)


func _update_activations(layer_idx, activations: Matrix):
	for row in range(activations.no_of_rows):
		var activation = activations.get_index(row, 0)
		var layer = layer_container.get_child(layer_idx)
		var color = ACTIVATION_COLOR_POSITIVE
		if activation < 0:
			color = ACTIVATION_COLOR_NEGATIVE
		if is_equal_approx(activation, 0):
			color = ACTIVATION_COLOR_INACTIVE
		else:
			color.a = abs(activation)

		layer.get_child(row - 1).modulate = color
	queue_redraw()


func _generate_layer() -> Node:
	var layer = preload("res://NetworkVisualizer/Nodes/Layer.tscn").instantiate()
	layer_container.add_child(layer)
	return layer


func _generate_node(layer):
	var node = preload("res://NetworkVisualizer/Nodes/Node.tscn").instantiate()
	node.custom_minimum_size *= SCALE
	layer.add_child(node)


func _draw() -> void:
	for line in lines:
		var start = line[0].global_position + (line[0].size / 2) - global_position
		var end = line[1].global_position + (line[1].size / 2) - global_position
		var color := LINE_COLOR_POSITIVE
		var width = abs(line[2]) * SCALE * 2
		if line[2] != 0:
			if line[2] < 0:
				color = LINE_COLOR_NEGATIVE
		else :
			color = Color.BLACK
			width = 1
		draw_line(start, end, color, width)
