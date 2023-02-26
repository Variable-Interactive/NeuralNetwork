extends KinematicBody2D

var sizes = [4, 16, 16, 16, 16, 1]
var net: Network

# Input
var focus_points

var jump_vel = 250
var velocity = Vector2.ZERO
var gravity = 10
var level: Node2D
var initial_time: float

signal destroyed(network, time)


func _ready() -> void:
	initial_time = Time.get_ticks_msec()
	level = get_tree().current_scene

	# set inheritance if any
	if AiMonitor.next_gen_networks.size() > 0:
		net = AiMonitor.next_gen_networks.pop_back()
	else:
		 net = Network.new(sizes)

	##### add this player to observer unit #####
	# warning-ignore:return_value_discarded
	connect("destroyed", AiMonitor, "_player_destroyed")
	############################################

	$Sprite.modulate = Color(randf(), randf(), randf(), 1)


func _process(_delta: float) -> void:
	focus_points = get_closest_points()
	$RayCast2D.cast_to = focus_points[0]
	$RayCast2D2.cast_to = focus_points[1]
	velocity.y += gravity

	#### Setting inputs to the network ########
	var input = [focus_points[0].x, focus_points[0].y, focus_points[1].x, focus_points[1].y]
	var res = net.feedforward(input)
	if res[0] > 0.5 and $JumpRecoil.is_stopped():
		jump()
	###########################################

	velocity = move_and_slide(velocity)


func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacle"):
		queue_free()


func _exit_tree() -> void:
	emit_signal("destroyed", net, Time.get_ticks_msec() - initial_time)


func jump():
	$JumpRecoil.start()
	velocity.y = -jump_vel


func get_closest_points():
	var obs: Array = level.obstacles
	for idx in obs.size():
		var index = idx
		if obs[index].global_position.x > global_position.x:
			var distance_a = global_position.distance_to(obs[index].top.global_position)
			var point_a = global_position.direction_to(obs[index].top.global_position) * distance_a
			var distance_b = global_position.distance_to(obs[index].bottom.global_position)
			var point_b = global_position.direction_to(obs[index].bottom.global_position) * distance_b
			return [point_a, point_b]
	return Vector2.ZERO
