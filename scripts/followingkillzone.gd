extends Area2D

@onready var timer: Timer = $Timer
@onready var player = %Player

var offset_distance: float = 50.0
var highest_position: float = 0.0  # Track the highest position reached

func _ready() -> void:
	print("Following Killzone ready")
	print("Player reference: ", player)
	
	monitoring = true
	collision_mask = 2
	
	if player:
		global_position.y = player.global_position.y + offset_distance
		highest_position = global_position.y  # Initialize highest position
	else:
		push_error("Player reference not found!")
	
	if not is_connected("body_entered", _on_body_entered):
		connect("body_entered", _on_body_entered)

func _physics_process(delta: float) -> void:
	if not player:
		return
		
	var target_y: float = player.global_position.y + offset_distance
	
	# If target is higher than current position, move up
	# Remember: smaller Y values are "higher" in Godot
	if target_y < global_position.y:
		global_position.y = target_y
		highest_position = global_position.y

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		print("You fell out of the world!")
		Engine.time_scale = 0.5
		body.queue_free()
		timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
