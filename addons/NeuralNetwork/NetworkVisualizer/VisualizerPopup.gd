extends Window

# use this popup to initiate different visualizer nodes
@onready var visualizer_container: VBoxContainer = $"%VisualizerContainer"


func _on_close_requested() -> void:
	hide()
