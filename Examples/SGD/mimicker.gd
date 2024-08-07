extends Control

## In this example, The AI is trained to mimic whatever input the user is giving.

## The AI is trained using using mini-batch stochastic gradient descent.

var net :Network

func _ready() -> void:
	net = Network.new([5, 20, 5])
	# NOTE: it took roughly 12 seconds for my computer to train AI under the current settings.
	net.SGD(generate_training_data(), 1, 5, 1, generate_training_data().slice(0, 100))
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
