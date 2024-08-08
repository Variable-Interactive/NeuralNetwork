extends Control

## In this example, The AI is trained to mimic whatever input the user is giving.
## The AI is trained using using mini-batch stochastic gradient descent.

## The AI is pre-trained. to re-train the AI, remove the file `res://Examples/SGD/Network.json`

const SAVE_PATH = "res://Examples/SGD/Network.json"
var net :Network


func _ready() -> void:
	var properly_loaded = load_network(SAVE_PATH)
	if not properly_loaded:
		net = Network.new([5, 20, 5])
		# NOTE: it took roughly 12 seconds for my computer to train AI under the current settings.
		net.SGD(generate_training_data(), 1, 5, 1, generate_training_data().slice(0, 100))
		save_network(net, SAVE_PATH)
	net.add_visualizer($HBoxContainer/visual)


func generate_training_data() -> Array[Array]:
	# Yes, I know there are many duplicates in the data array.
	var data: Array[Array] = []
	for a in 5:
		for b in 5:
			for c in 5:
				for d in 5:
					for e in 5:
						var sample: Array[Matrix] = [Matrix.new(5, 1)]
						sample[0].set_index(a, 0, 1)
						sample[0].set_index(b, 0, 1)
						sample[0].set_index(c, 0, 1)
						sample[0].set_index(d, 0, 1)
						sample[0].set_index(e, 0, 1)
						# generate corresponding output
						sample.append(sample[0].clone())
						data.append(sample)
	## There are very less entries of samples where only one input is switched on, let's add more
	## of them to the mis
	for a in 5:
		var sample: Array[Matrix] = [Matrix.new(5, 1)]
		sample[0].set_index(a, 0, 1)
		# generate corresponding output
		sample.append(sample[0].clone())
		for b in 30:
			data.append(sample)
	## Now stir the mix, and feed it to the AI
	data.shuffle()
	return data


func update(button_pressed: bool) -> void:
	var inputs: PackedFloat32Array = []
	for input in %Inputs.get_children():
		inputs.append(input.button_pressed == true)
	var out = net.feedforward(inputs).to_array()
	for i in %Outputs.get_child_count():
		var output: CheckButton = %Outputs.get_child(i)
		output.button_pressed = out[i] > 0.7


func save_network(network: Network, path: String) -> bool:
	var serialized_data := network.serialize()
	if not serialized_data:
		push_error("File failed to save. Converting network data to dictionary failed.")
		return false
	var to_save := JSON.stringify(serialized_data, " ")
	if not to_save:
		push_error("File failed to save. Converting dictionary to JSON failed.")
		return false
	if not DirAccess.dir_exists_absolute(path.get_base_dir()):
		DirAccess.make_dir_recursive_absolute(path.get_base_dir())

	var file := FileAccess.open(path, FileAccess.WRITE)
	if FileAccess.get_open_error() == OK:
		file.store_string(to_save)
		file.close()
		return true
	return false


func load_network(path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	var err = FileAccess.get_open_error()
	if err != OK:
		push_error(("File failed to open. Error code %s (%s)") % [err, error_string(err)])
		return false
	var data_json := file.get_as_text()
	file.close()

	var test_json_conv := JSON.new()
	var error := test_json_conv.parse(data_json)
	if error != OK:
		push_error("Error, json file. Error code %s (%s)" % [error, error_string(error)])
		printerr("Error: ", error)
		printerr("Error Line: ", test_json_conv.get_error_line())
		printerr("Error String: ", test_json_conv.get_error_message())
		return false

	var result = test_json_conv.get_data()
	if typeof(result) != TYPE_DICTIONARY:
		push_error("Error, json parsed result is: %s" % typeof(result))
		return false

	net = Network.create_network_from_dictionary(result)
	return true
