extends PanelContainer

const SCALE = 2

const NODE_RADIUS := 6
const LINE_COLOR_POSITIVE := Color.RED
const LINE_COLOR_NEGATIVE := Color.BLUE

const ACTIVATION_COLOR_POSITIVE := Color.WHITE
const ACTIVATION_COLOR_INACTIVE := Color.BLACK
const ACTIVATION_COLOR_NEGATIVE := Color.BLUE  # would appear in 1st layer

var lines = []
var node_texture = preload("res://addons/NeuralNetwork/NetworkVisualizer/Assets/Node.png")

@onready var layer_container = $"%LayerContainer"
@onready var identifier: ColorRect = $"%identifier"


func visualize_network(network: Network) -> void:
	# generate a framework
	var sep = 0
	for i in network.sizes:
		if i > sep:
			sep = i
	layer_container.set("theme_override_constants/separation", max(10, sep * 4))
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
					var weight = network.weights[layer_number].get_index(
						current_node_idx, prev_node_idx
					)
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
			color = lerp(
				ACTIVATION_COLOR_INACTIVE, ACTIVATION_COLOR_NEGATIVE, clamp(abs(activation), 0, 1)
			)
		else:
			color = lerp(
				ACTIVATION_COLOR_INACTIVE, ACTIVATION_COLOR_POSITIVE, clamp(abs(activation), 0, 1)
			)

		layer.get_child(row - 1).self_modulate = color
		layer.get_child(row - 1).get_child(0).self_modulate = color.inverted()
		layer.get_child(row - 1).get_child(0).text = str(snappedf(activation, 0.1))
	queue_redraw()


func _generate_layer() -> Node:
	var layer = VBoxContainer.new()
	layer.alignment = BoxContainer.ALIGNMENT_CENTER
	layer_container.add_child(layer)
	return layer


func _generate_node(layer):
	var node_indicator = TextureRect.new()
	node_indicator.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node_indicator.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	node_indicator.custom_minimum_size = 2 * Vector2.ONE * NODE_RADIUS * SCALE
	node_indicator.texture = node_texture
	var label := Label.new()
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set("theme_override_font_sizes/font_size", 6 * SCALE)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	node_indicator.add_child(label)
	layer.add_child(node_indicator)


func _draw() -> void:
	for line in lines:
		var start = line[0].global_position + (line[0].size / 2) - global_position
		var end = line[1].global_position + (line[1].size / 2) - global_position
		var sigmoid_weight = sigmoid(line[2])
		var color = lerp(LINE_COLOR_NEGATIVE, LINE_COLOR_POSITIVE, sigmoid_weight)
		var width = sigmoid_weight * SCALE * 2
		if is_equal_approx(sigmoid_weight, 0):
			color = Color.BLACK
			width = 1
		draw_line(start, end, color, width)


func sigmoid(value: float) -> float:
	return 1.0 / (1.0 + exp(-value))
