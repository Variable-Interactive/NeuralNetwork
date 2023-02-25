extends Node2D


var speed = 200
onready var top = $Top
onready var bottom = $Bottom

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	position.x -= delta * speed
