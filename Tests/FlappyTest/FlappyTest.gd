extends Node2D

var obstacles = []


func _ready() -> void:
	AiMonitor.start_simulation()

	var obstacle = preload("res://Tests/FlappyTest/obstacle/Obstacle.tscn").instance()
	var point = randi() % 5
	obstacle.global_position = $Points.get_child(point).global_position
	$Obstacles.add_child(obstacle)
	obstacles.append(obstacle)

	# generate players
	for _i in range(AiMonitor.players_per_generation):
		var player = preload("res://Tests/FlappyTest/AI/FlappyBird.tscn").instance()
		var pos = $PlayerPoint.global_position
		pos.x = 47
		player.global_position = pos
		add_child(player)


func _on_SpawnTimer_timeout() -> void:
	var obstacle = preload("res://Tests/FlappyTest/obstacle/Obstacle.tscn").instance()
	var point = randi() % 5
	obstacle.global_position = $Points.get_child(point).global_position
	$Obstacles.add_child(obstacle)
	obstacles.append(obstacle)

	if obstacles[0].global_position.x < 0:
		var rem_obstacle = obstacles.pop_front()
		rem_obstacle.queue_free()
