class_name GeneticEvolution
extends Reference
# Written by Variable-ind (https://github.com/Variable-ind)

# Adjustable parameters
const CROSSOVER_EXTENT = 0.5  # 1 (means only parent 1) to 0 (means only parent 1)
const MAX_CROSSOVER_SPLITS: int = 1  # the max amount of splits a network can have

const MUTATION_DEGREE = 0.1  # 1 (means full mutation) to 0 (no mutation)
const PERCENTAGE_MUTATION = 0.5  # 0 to 1 (how much mutatated elements in next generation)

var current_generation: int = -1
var players_per_generation: int = 50

# parameters you need not bother with
var _random := RandomNumberGenerator.new()
var _last_winners_a: Network  # used to compare previous networks
var _last_winners_b: Network  # used to compare previous networks
var _alive: int = 0
var _current_gen_networks = []

signal simulation_over(next_gen)


func start_simulation():
	current_generation += 1
	_alive = players_per_generation
	_current_gen_networks.clear()


func add_network(player: Network):
	_current_gen_networks.append(player)
	_alive -= 1
	if _alive < 1:
		if _alive == 0:
			stop_simulation()


func stop_simulation():
	emit_signal("simulation_over", prepere_next_generation())


func prepere_next_generation() -> Array:
	# get winners of this generation
	_current_gen_networks.sort_custom(self, "_sort_networks")

	# These are the winners
	var winner_1: Network = _current_gen_networks.pop_back()
	var winner_2: Network = _current_gen_networks.pop_back()

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

	var next_gen_networks = []
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
				or (new_network.biases in _added_biases) # If we the crossover already exist
			):
				new_network = _mutate(winner_1)
		_added_biases.append(new_network.biases)
		next_gen_networks.append(new_network)
	return next_gen_networks


func _crossover(parent_1: Network, parent_2: Network = null) -> Network:
	# make a copy of parent_1
	var new_network: Network = Network.new(parent_1.sizes)
	new_network.biases = parent_1.biases.duplicate(true)
	new_network.weights = parent_1.weights.duplicate(true)

	_random.randomize()
	if parent_2 == null:
		return new_network

	var current_split = 0
	for i in range(new_network.num_layers - 2):
		var val_cross = _random.randf()
		if val_cross > 0.5:  # Heads
			if current_split < MAX_CROSSOVER_SPLITS:
				# interchange corresponding chromosomes
				new_network.biases[i] = parent_2.biases[i]
				new_network.weights[i] = parent_2.weights[i]
				current_split += 1
	return new_network


func _mutate(net: Network) -> Network:
	_random.randomize()
	var new_network: Network = Network.new(net.sizes)
	for i in new_network.biases.size():
		var value = _random.randf()
		if value < MUTATION_DEGREE: # don't mutate this layer's biases/weights
			new_network.biases[i] = net.biases[i].duplicate(true)
			new_network.weights[i] = net.weights[i].duplicate(true)
	return new_network


func _sort_networks(a: Network, b: Network) -> bool:
	if a.reward < b.reward:
		return true
	else:
		return false
