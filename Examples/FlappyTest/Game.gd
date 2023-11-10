extends Node2D

var obstacles = []
var obstacle_scene = preload("res://Examples/FlappyTest/Obstacle/Obstacle.tscn")
var player_scene = preload("res://Examples/FlappyTest/Player/FlappyBird.tscn")


func _ready() -> void:
	# show generation number (not really needed)
	$CanvasLayer/Interface/Label.text = str("Generation: ", GeneticEvolution.current_generation)

	# generate amount of players required by players GeneticEvolution algorithm
	for _player_idx in GeneticEvolution.players_per_generation:
		var player = player_scene.instantiate()
		player.global_position = $PlayerPoint.global_position
		player.modulation = Color(randf(), randf(), randf(), 1)
		$Players.add_child(player)

	spawn_obstacle()


func spawn_obstacle() -> void:
	# Spawn obstacles after regular intervals
	var obstacle = obstacle_scene.instantiate()
	var point = randi() % 5
	obstacle.global_position = $Points.get_child(point).global_position
	$Obstacles.add_child(obstacle)
	obstacles.append(obstacle)
	# see if there are any obstacles that are no longer needed
	if obstacles[0].global_position.x < 0:
		var redundant_obstacle = obstacles.pop_front()
		redundant_obstacle.queue_free()


func _on_SpawnTimer_timeout() -> void:
	spawn_obstacle()


func _on_force_next_generation_pressed() -> void:
	for player in $Players.get_children():
		player.queue_free()


func _on_Visualize_pressed() -> void:
	GeneticEvolution.visualizer_popup.popup_centered()
