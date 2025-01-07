extends Node

var score = 0
@onready var score_label = $"Player/Camera2D/Score"
@onready var player = %Player

func _ready() -> void:
	if not player:
		push_error("Player node not found!")
		return
		
	if not score_label:
		push_error("Score label node not found!")
		return

func _on_player_player_died() -> void:
	if player:
		player.visible = false
		player.set_physics_process(false)
		player.set_process(false)

func update_score_display():
	if score_label and player:
		score = player.score
		score_label.text = "Score: "+str(int(score))

func _process(_delta: float) -> void:
	if player and not player.get_is_dead():
		update_score_display()
