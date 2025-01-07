extends CharacterBody2D

# Signal declaration
signal player_died

const SPEED = 170.0
const JUMP_VELOCITY = -390.0
const SCORE_MULTIPLIER = 10  # Made this a constant for easy tweaking
const RESET_DELAY = 0.6  # Define reset delay as constant
const SPAWN_POSITION = Vector2(-8, 6)
const DEATH_ZONE_OFFSET = 350  # Same as fall_buffer, but as a constant

var gravity_magnitude : int = ProjectSettings.get_setting("physics/2d/default_gravity")
var max_height = 0.0
var current_height = 0.0
var _is_dead = false
var score = 0.0
var _is_dying = false  # New state to prevent death loop
var debug_counter = 0  # Add counter for debugging

@onready var timer = $Timer
@onready var deathzone = $popup
@onready var death_player = $Sounds/Death
@onready var jump_player = $Sounds/Jump

func _ready() -> void:
	# Ensure we're the only player instance
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 1:
		queue_free()
		return
		
	add_to_group("player")
	
	# Configure timer
	timer.one_shot = true
	timer.wait_time = RESET_DELAY
	timer.stop()
	
	reset_player()
	
	if not deathzone:
		push_error("Deathzone node not found!")
		return

func get_is_dead() -> bool:
	return _is_dead

func reset_player() -> void:
	timer.stop()
	position = SPAWN_POSITION
	max_height = position.y
	current_height = position.y
	_is_dead = false
	_is_dying = false
	visible = true
	set_physics_process(true)
	set_process(true)
	velocity = Vector2.ZERO
	score = 0
	debug_counter = 0
	Engine.time_scale = 1

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
	if death_player:
		death_player.play()
	print("[Player] Emitting death signal...")
	emit_signal("player_died")
	
	# Slow down time and start reset timer
	Engine.time_scale = 0.5
	print("[Player] Starting death timer...")
	timer.start()

func _process(_delta: float) -> void:
	if _is_dead or _is_dying:
		return
		
	# Update current height
	current_height = position.y
	
	# Update max height only when going up
	if velocity.y < 0 and current_height < max_height:
		max_height = current_height
		score = abs(SPAWN_POSITION.y - max_height) * SCORE_MULTIPLIER
	
	# Update deathzone position
	if deathzone:
		deathzone.position.y = max_height + DEATH_ZONE_OFFSET
	
	# Die if fallen too far from max height
	if current_height > max_height + DEATH_ZONE_OFFSET:
		die()

func _on_timer_timeout() -> void:
	if timer.is_stopped():
		reset_player()

func _physics_process(delta: float) -> void:
	if _is_dead or _is_dying:
		return
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity_magnitude * delta
	else:
		# Auto-jump when touching the ground
		velocity.y = JUMP_VELOCITY
		if jump_player:
			jump_player.play()
	
	# Horizontal movement
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
