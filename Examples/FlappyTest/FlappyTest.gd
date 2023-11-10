extends Node2D

var obstacles = []


func _ready() -> void:
	$CanvasLayer/Interface/Label.text = str("Generation: ", GeneticEvolution.current_generation)

	var obstacle = preload("res://Examples/FlappyTest/obstacle/Obstacle.tscn").instantiate()
	var point = randi() % 5
	obstacle.global_position = $Points.get_child(point).global_position
	$Obstacles.add_child(obstacle)
	obstacles.append(obstacle)

	# generate players
	for _i in range(GeneticEvolution.players_per_generation):
		var player = preload("res://Examples/FlappyTest/AI/FlappyBird.tscn").instantiate()
		var pos = $PlayerPoint.global_position
		pos.x = 47
		player.global_position = pos
		player.modulation = Color(randf(), randf(), randf(), 1)
		$Players.add_child(player)

		var network_visualizer = preload("res://NetworkVisualizer/NetworkVisualizer.tscn").instantiate()
		GeneticEvolution.visualizer_popup.visualizer_container.add_child(network_visualizer)
		player.visualizer = network_visualizer
		network_visualizer.identifier.color = player.modulation
		network_visualizer.visualize_network(player.net)


func _on_SpawnTimer_timeout() -> void:
	var obstacle = preload("res://Examples/FlappyTest/obstacle/Obstacle.tscn").instantiate()
	var point = randi() % 5
	obstacle.global_position = $Points.get_child(point).global_position
	$Obstacles.add_child(obstacle)
	obstacles.append(obstacle)
	if obstacles[0].global_position.x < 0:
		var rem_obstacle = obstacles.pop_front()
		rem_obstacle.queue_free()


func _on_force_next_generation_pressed() -> void:
	for player in $Players.get_children():
		player.queue_free()


func _on_Visualize_pressed() -> void:
	GeneticEvolution.visualizer_popup.popup_centered()


