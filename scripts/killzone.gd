extends Area2D

@onready var timer: Timer = $Timer

func _ready() -> void:
	monitoring = true
	collision_mask = 2  # Set to match player's layer

func _on_body_entered(body: Node2D) -> void:
	print("Body entered: ", body)
	# Try without the player reference check first
	print("You died!")
	Engine.time_scale = 0.5
	body.queue_free()
	timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
