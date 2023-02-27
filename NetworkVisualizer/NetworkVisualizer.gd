extends PanelContainer

const SCALE = 1

const LINE_COLOR_POSITIVE = Color.orangered
const LINE_COLOR_NEGATIVE = Color.blueviolet

const ACTIVATION_COLOR_POSITIVE = Color.white
const ACTIVATION_COLOR_INACTIVE = Color.black
const ACTIVATION_COLOR_NEGATIVE = Color.blue

var lines = []

onready var layer_container = $"%LayerContainer"
onready var identifier: ColorRect = $"%identifier"


func visualize_network(network: Network) -> void:
	# generate a framework
	for x in network.sizes.size():
		var layer = _generate_layer()
		for _y in range(network.sizes[x]):
			_generate_node(layer)
	# now set weights
	yield(get_tree(), "idle_frame")
	lines = update_weights(network)
	# warning-ignore:return_value_discarded
	network.connect("activation_changed", self, "_update_activations")
	update()


func update_weights(network: Network):
	var lines_array = []
	for layer_number in network.weights.size():
		for current_node_idx in network.weights[layer_number].size():
			for prev_node_idx in network.weights[layer_number][current_node_idx].size():
				var from = get_activation_node(layer_number, prev_node_idx)
				var to = get_activation_node(layer_number + 1, current_node_idx)
				var weight = network.weights[layer_number][current_node_idx][prev_node_idx]
				lines_array.append([from, to, weight])
	return lines_array


func get_activation_node(layer_idx, node_idx) -> TextureRect:
	var layer = layer_container.get_child(layer_idx)
	return layer.get_child(node_idx)


func _update_activations(layer_idx, activations: Array):
	for node_idx in activations.size():
		var activation = activations[node_idx][0]
		var layer = layer_container.get_child(layer_idx)
		var color = ACTIVATION_COLOR_POSITIVE
		if activation < 0:
			color = ACTIVATION_COLOR_NEGATIVE
		color.a = abs(activation)
		if activation == 0:
			color = ACTIVATION_COLOR_INACTIVE
		layer.get_child(node_idx).modulate = color


func _generate_layer() -> Node:
	var layer = preload("res://NetworkVisualizer/Nodes/Layer.tscn").instance()
	layer_container.add_child(layer)
	return layer


func _generate_node(layer):
	var node = preload("res://NetworkVisualizer/Nodes/Node.tscn").instance()
	node.rect_min_size *= SCALE
	layer.add_child(node)


func _draw() -> void:
	for line in lines:
		if line[2] != 0:
			var start = line[0].rect_global_position + (line[0].rect_size / 2) - rect_global_position
			var end = line[1].rect_global_position + (line[1].rect_size / 2) - rect_global_position
			var color := LINE_COLOR_POSITIVE
			if line[2] < 0:
				color = LINE_COLOR_NEGATIVE
			draw_line(start, end, color, abs(line[2]) * SCALE)
