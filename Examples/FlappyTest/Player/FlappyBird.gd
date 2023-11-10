extends CharacterBody2D

const LAYER_NODES = [2, 10, 10, 1]  # nodes in the respective layers of neural network
var ai: Network

var jump_vel = 250
var gravity = 10
var level: Node2D
var initial_time: int

var modulation: Color


func jump():
	$JumpRecoil.start()
	velocity.y = -jump_vel


func _ready() -> void:
	initial_time = Time.get_ticks_msec()
	level = get_tree().current_scene

	########## Initializing the AI Player ###########
	# If this is the first generation
	if GeneticEvolution.generation_networks.size() == 0:
		ai = Network.new(LAYER_NODES)
	# If we have a network provided by genetic algorithm
	else:
		ai = GeneticEvolution.generation_networks.pop_back()
	# you can add a visualizer as well if you want
	ai.add_visualizer(GeneticEvolution.visualizer_popup.visualizer_container, modulation)
	#################################################

	$Sprite2D.self_modulate = modulation


func _process(_delta: float) -> void:
	#### Setting inputs to the NeuralNetwork ##
	var input = _get_input_points()  # geting the inputs
	var decision = ai.feedforward(input)  # feeding the inputs
	var should_jump = decision[0] > 0.5
	###########################################

	velocity.y += gravity
	if should_jump and $JumpRecoil.is_stopped():
		jump()
	move_and_slide()


func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacle"):
		queue_free()


func _exit_tree() -> void:
	########### remove Visualizer ############
	ai.destroy_visualizer()
	############ Grant a reward based on survival time ###############
	ai.give_reward(Time.get_ticks_msec() - initial_time)
	# Add to the monitor
	GeneticEvolution.submit_network(ai)
	###########################################


func _get_input_points() -> Array[float]:
	var obstacles: Array = level.obstacles
	for idx in obstacles.size():
		var index = idx
		if obstacles[index].global_position.x > global_position.x:
			var distance = global_position.distance_to(obstacles[index].global_position)
			var point = global_position.direction_to(obstacles[index].global_position) * distance
			return [point.x, point.y]
	return [0, 0]
