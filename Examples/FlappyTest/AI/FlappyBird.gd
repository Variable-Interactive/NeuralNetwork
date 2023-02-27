extends KinematicBody2D

var sizes = [2, 16, 4, 1]  # nodes in the respective layers
var net: Network

var jump_vel = 250
var velocity = Vector2.ZERO
var gravity = 10
var level: Node2D
var initial_time: float

var modulation: Color

func jump():
	$JumpRecoil.start()
	velocity.y = -jump_vel


func _ready() -> void:
	initial_time = Time.get_ticks_msec()
	level = get_tree().current_scene

	########## The AI Initialization ###########
	# set inheritance if any is assigned by the genetic algorithm
	if AiMonitor.next_gen_networks.size() > 0:
		net = AiMonitor.next_gen_networks.pop_back()
	else:
		 net = Network.new(sizes)
	############################################

	$Sprite.modulate = modulation


func _process(_delta: float) -> void:
	velocity.y += gravity

	#### Setting inputs to the NeuralNetwork ##
	var input = _get_input_points()
	var res = net.feedforward(input)
	if res[0] > 0.5 and $JumpRecoil.is_stopped():
		jump()
	###########################################

	velocity = move_and_slide(velocity)


func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacle"):
		###### remove Visualizer #####
		var idx = get_index()
		var visualizer_container = AiMonitor.visualizer_popup.visualizer_container
		var visualizer: PanelContainer = visualizer_container.get_child(idx)
		if visualizer:
			visualizer.queue_free()
		##############################
		queue_free()


func _exit_tree() -> void:
	############ Grant a reward ###############
	net.reward = Time.get_ticks_msec() - initial_time
	# Add to the monitor
	AiMonitor.player_destroyed(net)
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
