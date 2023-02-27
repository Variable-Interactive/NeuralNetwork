extends Node


var gen := GeneticEvolution.new()

var next_gen_networks: Array = []


var visualizer_popup

func _ready() -> void:
	visualizer_popup = preload("res://NetworkVisualizer/VisualizerPopup.tscn").instance()
	add_child(visualizer_popup)
	visualizer_popup.popup_centered()
	# warning-ignore:return_value_discarded
	gen.connect("simulation_over", self, "_simulation_over")


func player_destroyed(network: Network):
	# add network to the list for evaluation
	gen.add_network(network)


func _simulation_over(next_generation):
	next_gen_networks = next_generation
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
