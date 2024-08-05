extends CharacterBody2D

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
	$Sprite2D.self_modulate = modulation


func _process(_delta: float) -> void:
	#### Setting inputs to the NeuralNetwork ##
	var input = _get_input_points()  # getting the inputs
	var decision: Matrix = ai.feedforward(input, ai.Activation.RELU)  # feeding the inputs
	var should_jump = decision.get_index(0, 0) > 0.5
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
	var reward = Time.get_ticks_msec() - initial_time
	# Add to the monitor
	GeneticEvolution.submit_network(ai, reward)
	###########################################


func _get_input_points() -> Array[float]:
	var obstacles: Array = level.obstacles
	for idx in obstacles.size():
		var index = idx
		if obstacles[index].global_position.x > global_position.x:
			#var distance = global_position.distance_to(obstacles[index].global_position)
			var point = global_position.direction_to(obstacles[index].global_position)# * distance
			return [point.x, point.y]
	return [0, 0]
