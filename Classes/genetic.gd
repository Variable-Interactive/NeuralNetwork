class_name GeneticEvolution
extends Reference

const MAX_CROSSOVER_SPLITS = 2
const MUTATION_DEGREE = 0.5  # 1 (means full mutation) to 0 (no mutation)
var random := RandomNumberGenerator.new()


func prepere_next_generation(networks: Array, player_per_gen: int):
	# get winners of this generation
	networks.sort_custom(self, "_sort_networks")

	# These are the winners
	var winner_1: Network = networks.pop_back()
	var winner_2: Network = networks.pop_back()

	var next_gen_networks = []
	for i in range(player_per_gen):
		var new_network: Network
		if i < 1: # keep 1 best from the last generation
			new_network = _crossover(winner_1)
		else:
			# Make a crossover
			new_network = _crossover(winner_1, winner_2)
			var can_mutate = randf()
			if can_mutate < 0.5: # If we need mutation not crossover
				new_network = _mutate(winner_1)
		next_gen_networks.append(new_network)


func _crossover(parent_1: Network, parent_2: Network = null) -> Network:
	# make a copy of parent_1
	var new_network: Network = Network.new(parent_1.sizes)
	new_network.biases = parent_1.biases.duplicate(true)
	new_network.weights = parent_1.weights.duplicate(true)
	random.randomize()
	if parent_2 == null:
		return new_network

	var current_split = 0
	for i in range(new_network.num_layers - 2):
		var val_cross = random.randf()
		if val_cross < 0.5:  # Heads
			if current_split > MAX_CROSSOVER_SPLITS:
				# interchange corresponding chromosomes
				new_network.biases[i] = parent_2.biases[i]
				new_network.weights[i] = parent_2.weights[i]
				current_split += 1
	return new_network


func _mutate(net: Network) -> Network:
	random.randomize()
	var new_network: Network = Network.new(net.sizes)
	for i in new_network.biases.size():
		var value = random.randf()
		if value > MUTATION_DEGREE: # don't mutate this layer's biases/weights
			new_network.biases[i] = net.biases[i].duplicate(true)
			new_network.weights[i] = net.weights[i].duplicate(true)
	return new_network


func _sort_networks(a: Network, b: Network) -> bool:
	if a.reward < b.reward:
		return true
	else:
		return false
