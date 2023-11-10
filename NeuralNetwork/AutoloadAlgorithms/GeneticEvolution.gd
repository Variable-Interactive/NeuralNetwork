extends Node
# GeneticEvolution algorithm written by Variable-ind (https://github.com/Variable-ind)

signal simulation_over(next_gen)

# Adjustable parameters
const CROSSOVER_EXTENT = 0.5  # 1 (means only parent 1) to 0 (means only parent 1)
const MAX_CROSSOVER_SPLITS: int = 1  # the max amount of splits a network can have

const PERCENTAGE_MUTATION = 0.5  # 0 to 1 (how much mutatated networks in next generation)
const MUTATION_DEGREE = 0.5  # values from 1 (network is fully mutated) to 0 (no mutation in network)

var players_per_generation: int = 10

# parameters you need not bother with
var current_generation: int = 0
var _random := RandomNumberGenerator.new()
var _last_winners_a: Network  # used to compare previous networks
var _last_winners_b: Network  # used to compare previous networks
var _dead: int = 0
var _submitted_gen_networks = []

var generation_networks: Array = []
var visualizer_popup


func _ready() -> void:
	visualizer_popup = preload("res://NetworkVisualizer/VisualizerPopup.tscn").instantiate()
	add_child(visualizer_popup)
	visualizer_popup.popup_centered()


func submit_network(player: Network):
	_submitted_gen_networks.append(player)
	_dead += 1
	if _dead == players_per_generation:
		_session_ended()


func _session_ended():
	emit_signal("simulation_over")
	_prepere_next_generation()
	current_generation += 1
	_dead = 0
	_submitted_gen_networks.clear()
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()


func _prepere_next_generation():
	# get winners of this generation
	_submitted_gen_networks.sort_custom(Callable(self, "_sort_networks"))

	# These are the winners
	var winner_1: Network = _submitted_gen_networks.pop_back()
	var winner_2: Network = _submitted_gen_networks.pop_back()

	# we will compare the performance of this generation with the previous one
	# and if this generation is poor, then discard it
	if _last_winners_a and _last_winners_b:
		if winner_1.reward > _last_winners_a.reward:
			_last_winners_a = winner_1
		else:
			winner_1 = _last_winners_a
		if winner_2.reward > _last_winners_b.reward:
			_last_winners_b = winner_2
		else:
			winner_2 = _last_winners_b
	else:
		_last_winners_a = winner_1
		_last_winners_b = winner_2

	generation_networks.clear()
	var _added_biases = [] # to check if a network already exists
	for i in range(players_per_generation):
		var new_network: Network
		if i < 1: # keep 1 best from the last generation
			new_network = _crossover(winner_1)
		else:
			# Make a crossover
			new_network = _crossover(winner_1, winner_2)
			var can_mutate = randf()
			if (
				(can_mutate < PERCENTAGE_MUTATION) # If we need mutation not crossover
			):
				new_network = _mutate(winner_1)
		_added_biases.append(new_network.biases)
		generation_networks.append(new_network)


func _crossover(parent_1: Network, parent_2: Network = null) -> Network:
	# make a copy of parent_1
	var new_network: Network = Network.new(parent_1.sizes)
	new_network.biases = parent_1.biases.duplicate(true)
	new_network.weights = parent_1.weights.duplicate(true)

	_random.randomize()
	if parent_2 == null:
		return new_network

	var current_split = 0
	for i in range(new_network.num_layers - 1):  # total biases/weights are 1 less than layer count.
		var val_cross = _random.randf()
		if val_cross > 0.5:  # Heads
			if current_split < MAX_CROSSOVER_SPLITS:
				# interchange corresponding chromosomes
				new_network.biases[i] = parent_2.biases[i].copy()
				new_network.weights[i] = parent_2.weights[i].copy()
				current_split += 1
	return new_network


func _mutate(net: Network) -> Network:
	_random.randomize()
	var new_network: Network = Network.new(net.sizes)
	for layer in range(new_network.num_layers - 1):  # total biases/weights are 1 less than layer count.
		new_network.biases[layer] = net.biases[layer].copy()
		new_network.weights[layer] = net.weights[layer].copy()
		var should_mutate_bias = _random.randf()
		var should_mutate_weight = _random.randf()
		if should_mutate_bias <= MUTATION_DEGREE: # mutate this layer's biases
			var rand_mat = Matrix.new(
				net.biases[layer].no_of_rows, net.biases[layer].no_of_columns, true
			)
			new_network.biases[layer] = net.biases[layer].multiply_corresponding(rand_mat, false)
		if should_mutate_weight <= MUTATION_DEGREE: # don't mutate this layer's weights
			var rand_mat = Matrix.new(
				net.weights[layer].no_of_rows, net.weights[layer].no_of_columns, true
			)
			new_network.weights[layer] = net.weights[layer].multiply_corresponding(rand_mat, false)
	return new_network


func _sort_networks(a: Network, b: Network) -> bool:
	if a.reward < b.reward:
		return true
	else:
		return false
