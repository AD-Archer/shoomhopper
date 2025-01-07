extends Node

var score = 345434343
@onready var score_label = $"Player/Camera2D/Score"
@onready var player = $Player

func _ready() -> void:
	if not player:
		push_error("Player node not found!")
		return
		
	if not score_label:
		push_error("Score label node not found!")
		return
		
	player.connect("player_died", _on_player_player_died)
	
func _on_player_player_died() -> void:
	if player:
		player.queue_free()

func cal_score():
	if score_label:
		score_label.text = str(score)

func _process(delta: float) -> void:
	if player and not player.get_is_dead():
		cal_score()
