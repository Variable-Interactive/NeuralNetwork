extends Node2D


func _ready() -> void:
	AiMonitor.start_simulation()

	# generate players
	for _i in range(AiMonitor.players_per_generation):
		var player = preload("res://Tests/LevitationTest/AI/Levitator.tscn").instance()
		var pos = $Points.get_child(randi() % 8).global_position
		player.global_position = pos
		$Players.add_child(player)


func _on_over_timeout() -> void:
	for player in $Players.get_children():
		player.queue_free()
