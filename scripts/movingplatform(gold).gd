extends StaticBody2D

var move_distance : float = 240.0
var speed : float = 100.0
var start_position : Vector2
var direction : int = 1

func _ready() -> void:
	start_position = position
	
	# Randomize movement parameters for variety
	move_distance = randf_range(150.0, 300.0)
	speed = randf_range(80.0, 120.0)
	direction = 1 if randf() > 0.5 else -1

func _process(delta: float) -> void:
	position.x += direction * speed * delta
	
	if position.x >= start_position.x + move_distance:
		direction = -1
	elif position.x <= start_position.x - move_distance:
		direction = 1
