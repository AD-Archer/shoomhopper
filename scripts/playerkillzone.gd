extends Area2D

@onready var timer: Timer = $Timer
@onready var player = %Player  # Replace with the path to your player node
var distance_behind_player = 100.0  # The distance behind the player the kill zone should stay
var kill_zone_speed = 100.0  # Speed at which the kill zone moves (optional, if you want to move it with speed)

func _process(delta: float) -> void:
	# Calculate the target position for the kill zone (a fixed distance behind the player)
	var target_position = player.position + Vector2(0, distance_behind_player)
	
	# Move the kill zone towards that target position smoothly
	var direction = (target_position - position).normalized()
	position += direction * kill_zone_speed * delta
	
	# Optionally, if the kill zone is already at the target position, stop further movement
	# This behavior will make the kill zone stop moving once it reaches the desired position
	if position.distance_to(target_position) < 1:
		position = target_position

# Trigger when a body enters the kill zone
func _on_body_entered(body: CharacterBody2D) -> void:
	print("You died!")
	Engine.time_scale = 0.5
	
	body.queue_free()
	
	timer.start()

# When the timer times out, reload the scene
func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
