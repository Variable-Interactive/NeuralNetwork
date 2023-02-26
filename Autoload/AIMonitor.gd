extends Node

var players_per_generation: int = 100

var gen := GeneticEvolution.new()
var current_generation: int = -1

var networks: Array = []
var next_gen_networks: Array = []

var players: int = 0


func start_simulation():
	current_generation += 1
	players = players_per_generation
	networks.clear()


func _add_network(player_network: Network):
	networks.append(player_network)


func _player_destroyed(network: Network, time: float):
	# Grant a reward based on performance
	network.reward = time

	# add network to the list for evaluation later
	_add_network(network)
	players -= 1
	if players < 1:
		if players == 0:
			# all players are done so stop simulation
			_simulation_over()


func _simulation_over():
	gen.prepere_next_generation(networks, players_per_generation)
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
