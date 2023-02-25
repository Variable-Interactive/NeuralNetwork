class_name GeneticEvolution
extends Reference

var random := RandomNumberGenerator.new()

func sort_by_rewards(networks: Array = []):
	networks.sort_custom(self, "_sort_networks")
	return networks


# this function is not really used
func evaluate_network(network: Network, networks: Array = []) -> float:
	var total_rewards: float = 0
	for i in networks.size():
		total_rewards += networks[i].reward
	if total_rewards == 0: # no progress done
		printerr("zero progress")
		return 0.0
	return network.reward / total_rewards


func crossover(net_1: Network, net_2: Network, inheritance):
	# 0 inheritance means only net_1, 1 means only net 2
	random.randomize()
	var new_network: Network = Network.new(net_1.sizes)
	new_network.biases = net_1.biases.duplicate(true)
	new_network.weights = net_1.weights.duplicate(true)
	for i in range(new_network.num_layers - 2):
		var val_cross = random.randf()
		if val_cross < inheritance:  # Heads
			# interchange corresponding chromosomes
			new_network.biases[i] = net_2.biases[i]
	return new_network


func try_mutating(net: Network, mutating_threshold: float):
	var mat := Matrix.new()
	for weight_idx in net.weights.size():
		net.weights[weight_idx] = mat.mutate_matrix(net.weights[weight_idx], mutating_threshold)
	for i in net.biases.size():
		net.biases[i] = mat.mutate_matrix(net.biases[i], mutating_threshold)


func _sort_networks(a: Network, b: Network) -> bool:
	if a.reward < b.reward:
		return true
	else:
		return false
