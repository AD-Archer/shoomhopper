# player.gd
extends CharacterBody2D

# Signal must be declared at the top
signal player_died

const SPEED = 170.0
const JUMP_VELOCITY = -390.0
const SCORE_MULTIPLIER = 10  # Made this a constant for easy tweaking
const RESET_DELAY = 0.6  # Define reset delay as constant

var gravity_magnitude : int = ProjectSettings.get_setting("physics/2d/default_gravity")
var fall_buffer = 350 # how far player can fall without dying
var max_height = 0.0
var _is_dead = false
var score = 0.0
var _is_dying = false  # New state to prevent death loop
var debug_counter = 0  # Add counter for debugging

@onready var timer = $Timer

# Load sounds with error checking
var death_sound: AudioStream
var jump_sound: AudioStream

func _ready() -> void:
	print("[Player] Initializing...")
	death_sound = load("res://assets/sounds/explosion.wav")
	jump_sound = load("res://assets/sounds/jump.wav")
	if not death_sound or not jump_sound:
		push_warning("[Player] Some sound files couldn't be loaded!")
	
	# Configure timer
	timer.one_shot = true  # Make sure timer only fires once
	timer.wait_time = RESET_DELAY
	timer.stop()  # Make sure timer is stopped initially
	
	reset_player()

func play_sound(sound: AudioStream) -> void:
	if not sound:
		return
	
	var audio = AudioStreamPlayer.new()
	audio.stream = sound
	add_child(audio)
	audio.play()
	await audio.finished
	audio.queue_free()

func get_is_dead() -> bool:
	return _is_dead

func reset_player() -> void:
	timer.stop()  # Make sure timer is stopped
	position = Vector2(-8, 6)
	max_height = position.y
	_is_dead = false
	_is_dying = false
	visible = true
	set_physics_process(true)
	set_process(true)
	velocity = Vector2.ZERO
	score = 0
	debug_counter = 0  # Reset counter
	Engine.time_scale = 1  # Reset time scale

func die() -> void:
	
	if _is_dead or _is_dying:
		print("[Player] Die() blocked - already dead or dying")
		return
		
	_is_dying = true
	_is_dead = true
	print("[Player] Death sequence starting. Score:", int(score))
	
	# Stop all movement immediately
	velocity = Vector2.ZERO
	set_physics_process(false)
	
	# Play death sound and emit signal
	print("[Player] Playing death sound...")
	play_sound(death_sound)
	print("[Player] Emitting death signal...")
	emit_signal("player_died")
	
	# Slow down time and start reset timer
	Engine.time_scale = 0.5
	print("[Player] Starting death timer...")
	timer.start()  # Timer will only fire once due to one_shot = true

func _process(_delta: float) -> void:
	if _is_dead or _is_dying:
		return
		
	if velocity.y < 0 and position.y < max_height:
		max_height = position.y
		score = (abs(max_height - position.y) + abs(max_height)) * SCORE_MULTIPLIER
	if position.y > max_height + fall_buffer:
		die()

func _on_timer_timeout() -> void:
	if timer.is_stopped():  # Only reset if timer is actually stopped
		reset_player()


func _physics_process(delta: float) -> void:
	if _is_dead or _is_dying:
		return
	
	if not is_on_floor():
		velocity.y += gravity_magnitude * delta
	else:
		velocity.y = JUMP_VELOCITY
		play_sound(jump_sound)
	
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
# -239 is the platform
