extends KinematicBody2D

var sizes = [2, 10, 10, 1]

var jump_vel = 250
var velocity = Vector2.ZERO
var gravity = 10
var level: Node2D
var net = Network.new(sizes)

var focus_point

func _ready() -> void:
	level = get_tree().current_scene


func _process(_delta: float) -> void:
	focus_point = get_closest_point()
	$RayCast2D.cast_to = focus_point
	velocity.y += gravity

	var input = [[focus_point.x], [focus_point.y]]
	var res = net.feedforward(input)
	if res[0][0] < 0.4 and $JumpRecoil.is_stopped():
		jump()
	velocity = move_and_slide(velocity)


func jump():
	velocity.y = -jump_vel


func get_closest_point():
	var obs: Array = level.obstacles
	for idx in obs.size():
		var index = idx
		if obs[index].global_position.x > global_position.x:
			var distance = global_position.distance_to(obs[index].global_position)
			return global_position.direction_to(obs[index].global_position) * distance
	return Vector2.ZERO


func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacle"):
		queue_free()
