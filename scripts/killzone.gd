extends Area2D

@onready var timer: Timer = $Timer

func _ready() -> void:
	monitoring = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not body.get_is_dead():
		body.die()

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
