extends Node2D

@export var platform_scene: PackedScene
@export var path: Path2D
@export_group("Spawn Settings")
@export var spawn_width: float = 400.0
@export var spawn_height: float = 2000.0
@export var platforms_per_row: int = 2
@export var row_spacing: float = 70.0
@export var horizontal_offset: float = 80.0

var player: CharacterBody2D
var player_x: float = 0.0
var player_is_dead: bool = false
var spawned_platforms: Array[Node] = []

# Assuming gravity and jump velocity are set in project settings
var gravity_magnitude: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_velocity: float = -330.0  # Modify this if needed

# Calculate the max jump height
var max_jump_height: float

# Define minimum and maximum row spacing to prevent platforms being too close or too far
@export var min_row_spacing: float = 50.0  # Minimum spacing between platforms
@export var max_row_spacing: float = 150.0  # Maximum spacing between platforms

func _ready() -> void:
	player = get_node("%Player")
	
	if not platform_scene:
		platform_scene = preload("res://scenes/movingplatform(gold).tscn")
	
	if not player:
		push_error("Player not found! Enable 'Scene Unique Name' on Player node")
		return
	
	# Connect to player death signal
	player.tree_exiting.connect(_on_player_died)
	
	# Initialize player position and spawn platforms
	player_x = player.global_position.x
	
	# Calculate max jump height
	max_jump_height = (jump_velocity ** 2) / (2 * gravity_magnitude)
	
	spawn_platforms()

func _process(_delta: float) -> void:
	if is_instance_valid(player) and not player_is_dead:
		player_x = player.global_position.x

func _on_player_died() -> void:
	player_is_dead = true
	player = null

func spawn_platforms() -> void:
	var spawn_center := Vector2.ZERO
	var spawn_bounds := Rect2(
		spawn_center.x - spawn_width/2,
		spawn_center.y - spawn_height/2,
		spawn_width,
		spawn_height
	)
	
	if path:
		spawn_bounds = path.get_baked_bounds()
	
	var num_rows := int(spawn_bounds.size.y / row_spacing)
	
	for row in num_rows:
		var row_y := spawn_bounds.position.y + (row * row_spacing)
		var row_offset := horizontal_offset if row % 2 == 0 else -horizontal_offset
		
		for i in platforms_per_row:
			var platform := platform_scene.instantiate() as Node2D
			add_child(platform)
			
			# Calculate zigzag pattern position
			var base_x := spawn_bounds.position.x + (spawn_bounds.size.x / 2) + row_offset
			
			# Add slight randomness
			var random_offset := Vector2(
				randf_range(-20, 20),
				randf_range(-10, 10)
			)
			
			platform.position = Vector2(base_x, row_y) + random_offset
			spawned_platforms.append(platform)
	
			# Adjust row spacing to ensure platforms are jumpable
			adjust_platform_spacing()

func adjust_platform_spacing() -> void:
	# Calculate adjusted row spacing based on max jump height
	var adjusted_row_spacing = max_jump_height * 1.5  # You can tweak this multiplier for challenge
	# Clamp the row spacing between minimum and maximum allowed values
	row_spacing = clamp(adjusted_row_spacing, min_row_spacing, max_row_spacing)

func _exit_tree() -> void:
	# Clean up platforms when scene changes
	for platform in spawned_platforms:
		if is_instance_valid(platform):
			platform.queue_free()
