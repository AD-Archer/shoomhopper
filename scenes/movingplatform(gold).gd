extends StaticBody2D

var move_distance : float = 100.0
var speed : float = 30.0
var start_position : Vector2
var direction : int = 1

func _ready() -> void:
	start_position = position

func _process(delta: float) -> void:
	position.x += direction * speed * delta
	
	if position.x >= start_position.x + move_distance:
		direction = -1
	elif position.x <= start_position.x - move_distance:
		direction = 1
