extends KinematicBody2D

var sizes = [2, 16, 16, 16, 1]
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

	# set inheritance if any
	if AiMonitor.next_gen_networks.size() > 0:
		net = AiMonitor.next_gen_networks.pop_back()
	else:
		 net = Network.new(sizes)

	##### add this player to observer unit #####
	# warning-ignore:return_value_discarded
	connect("destroyed", AiMonitor, "_player_destroyed")
	############################################


func _process(_delta: float) -> void:
	velocity.y += gravity

	#### Setting inputs to the network ########
	var input = [[global_position.x], [global_position.y]]
	var res = net.feedforward(input)
	if res[0][0] * 2 > 1.9 and $JumpRecoil.is_stopped():
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
