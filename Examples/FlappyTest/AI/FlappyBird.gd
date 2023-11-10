extends CharacterBody2D

var sizes = [2, 10, 10, 1]  # nodes in the respective layers
var net: Network

var jump_vel = 250
var gravity = 10
var level: Node2D
var initial_time: int

var modulation: Color

var visualizer


func jump():
	$JumpRecoil.start()
	velocity.y = -jump_vel
	# give reward for jumping
	net.give_reward(1)


func _ready() -> void:
	initial_time = Time.get_ticks_msec()
	level = get_tree().current_scene

	########## Initializing the AI Player ###########
	# If this is the first generation
	if GeneticEvolution.generation_networks.size() == 0:
		net = Network.new(sizes)
	# If we have a network provided by genetic algorithm
	else:
		net = GeneticEvolution.generation_networks.pop_back()
	#################################################

	$Sprite2D.modulate = modulation


func _process(_delta: float) -> void:
	#### Setting inputs to the NeuralNetwork ##
	var input = _get_input_points()  # geting the inputs
	var decision = net.feedforward(input)  # feeding the inputs
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
	visualizer.queue_free()
	############ Grant a reward based on distance ###############
	net.give_reward(Time.get_ticks_msec() - initial_time)
	# Add to the monitor
	GeneticEvolution.submit_network(net)
	###########################################


func _get_input_points():
	var obs: Array = level.obstacles
	for idx in obs.size():
		var index = idx
		if obs[index].global_position.x > global_position.x:
			var distance = global_position.distance_to(obs[index].global_position)
			var point = global_position.direction_to(obs[index].global_position) * distance
			return [point.x, point.y]
	return [0, 0]
