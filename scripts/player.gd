
# player.gd
extends CharacterBody2D

# Signal must be declared at the top
signal player_died

const SPEED = 170.0
const JUMP_VELOCITY = -390.0

var gravity_magnitude : int = ProjectSettings.get_setting("physics/2d/default_gravity")
var fall_buffer = 350
var max_height = 0.0
var _is_dead = false

@onready var timer = $Timer

func _ready() -> void:
	max_height = position.y

func get_is_dead() -> bool:
	return _is_dead

func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	print("You died!")
	Engine.time_scale = 0.5
	timer.start()
	velocity = Vector2.ZERO
	set_physics_process(false)
	emit_signal("player_died")  # Alternative syntax for emission

func _process(delta: float) -> void:
	if velocity.y < 0 and position.y < max_height:
		max_height = position.y
	
	if position.y > max_height + fall_buffer and not _is_dead:
		die()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	
	if not is_on_floor():
		velocity.y += gravity_magnitude * delta
	else:
		velocity.y = JUMP_VELOCITY
	
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
