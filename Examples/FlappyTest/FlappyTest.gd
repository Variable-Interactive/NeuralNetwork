extends Node2D

var obstacles = []


func _ready() -> void:
	AiMonitor.gen.start_simulation()

	$CanvasLayer/Interface/Label.text = str("Generation: ", AiMonitor.gen.current_generation)
	var obstacle = preload("res://Examples/FlappyTest/obstacle/Obstacle.tscn").instance()
	var point = randi() % 5
	obstacle.global_position = $Points.get_child(point).global_position
	$Obstacles.add_child(obstacle)
	obstacles.append(obstacle)

	# generate players
	for _i in range(AiMonitor.gen.players_per_generation):
		var player = preload("res://Examples/FlappyTest/AI/FlappyBird.tscn").instance()
		var pos = $PlayerPoint.global_position
		pos.x = 47
		player.global_position = pos
		player.modulation = Color(randf(), randf(), randf(), 1)
		$Players.add_child(player)

		var network_visualizer = preload("res://NetworkVisualizer/NetworkVisualizer.tscn").instance()
		AiMonitor.visualizer_popup.visualizer_container.add_child(network_visualizer)
		network_visualizer.identifier.color = player.modulation
		network_visualizer.visualize_network(player.net)


func _on_SpawnTimer_timeout() -> void:
	var obstacle = preload("res://Examples/FlappyTest/obstacle/Obstacle.tscn").instance()
	var point = randi() % 5
	obstacle.global_position = $Points.get_child(point).global_position
	$Obstacles.add_child(obstacle)
	obstacles.append(obstacle)

	if obstacles[0].global_position.x < 0:
		var rem_obstacle = obstacles.pop_front()
		rem_obstacle.queue_free()


func _on_Button_pressed() -> void:
	for player in $Players.get_children():
		player.queue_free()


func _on_Visualize_pressed() -> void:
	AiMonitor.visualizer_popup.popup_centered()
