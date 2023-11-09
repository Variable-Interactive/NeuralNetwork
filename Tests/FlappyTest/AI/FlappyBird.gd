extends CharacterBody2D

var sizes = [2, 16, 1]  # nodes in the respective layers
var net: Network

var jump_vel = 250
var velocity = Vector2.ZERO
var gravity = 10
var level: Node2D
var initial_time: float

signal destroyed(network, time)


func _ready() -> void:
	initial_time = Time.get_ticks_msec()
	level = get_tree().current_scene

	########## The AI Initialization ###########
	# set inheritance if any is assigned by the genetic algorithm
	if AiMonitor.next_gen_networks.size() > 0:
		net = AiMonitor.next_gen_networks.pop_back()
	else:
		 net = Network.new(sizes)

	# add this player to observer unit
	# warning-ignore:return_value_discarded
	connect("destroyed", Callable(AiMonitor, "_player_destroyed"))
	############################################

	$Sprite2D.modulate = Color(randf(), randf(), randf(), 1)


func _process(_delta: float) -> void:
	velocity.y += gravity

	#### Setting inputs to the NeuralNetwork ########
	var input = get_input_points()
	var res = net.feedforward(input)
	if res[0] > 0.5 and $JumpRecoil.is_stopped():
		jump()
	###########################################

	set_velocity(velocity)
	move_and_slide()
	velocity = velocity


func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacle"):
		queue_free()


func _exit_tree() -> void:
	emit_signal("destroyed", net, Time.get_ticks_msec() - initial_time)


func jump():
	$JumpRecoil.start()
	velocity.y = -jump_vel


func get_input_points():
	var obs: Array = level.obstacles
	for idx in obs.size():
		var index = idx
		if obs[index].global_position.x > global_position.x:
			var distance = global_position.distance_to(obs[index].global_position)
			var point = global_position.direction_to(obs[index].global_position) * distance
			return [point.x, point.y]
	return [0, 0]
