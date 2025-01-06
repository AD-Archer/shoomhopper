extends Node2D

@export var platform_scene: PackedScene
@export var path: Path2D
@export var spawn_area_size: Vector2 = Vector2(400, 2000)  # Narrower, tall area
@export var platforms_per_row: int = 2  # Platforms per row
@export var row_spacing: float = 70.0  # Vertical distance between rows - tuned for jump height

@onready var player = %Player  # Reference to player
var player_x: float = 0.0     # Store player's X position
var player_is_dead: bool = false

# Default spawn area centered on screen
var default_spawn_rect := Rect2(Vector2(-200, -1000), Vector2(400, 2000))
var spawned_positions: Array[Vector2] = []

func _ready() -> void:
	print("PlatformSpawner ready")
	
	if not platform_scene:
		platform_scene = load("res://scenes/movingplatform(gold).tscn")
		if not platform_scene:
			push_error("Could not load movingplatform(gold).tscn!")
			return
	
	if not player:
		push_error("Player not found! Make sure it has Scene Unique Name enabled")
		return
		
	# Connect to player's tree_exiting signal to detect death
	player.tree_exiting.connect(_on_player_died)
	
	player_x = player.global_position.x  # Initial player X position
	spawn_platforms()

func _process(_delta: float) -> void:
	if player and not player_is_dead:
		player_x = player.global_position.x  # Update player X position
		# print("Player X: ", player_x)  # Uncomment to debug

func _on_player_died() -> void:
	player_is_dead = true
	player = null  # Clear the reference

func spawn_platforms() -> void:
	var spawn_bounds: Rect2
	
	if path:
		spawn_bounds = path.get_baked_bounds()
	else:
		spawn_bounds = default_spawn_rect
	
	# Calculate rows based on height
	var total_height = spawn_bounds.size.y
	var num_rows = int(total_height / row_spacing)
	
	# Spawn platforms in a zigzag pattern for easier jumping
	for row in range(num_rows):
		var row_y = spawn_bounds.position.y + (row * row_spacing)
		
		# Alternate platform positions for zigzag pattern
		var offset = 80.0 if row % 2 == 0 else -80.0
		
		# Spawn platforms at this height
		for i in range(platforms_per_row):
			var platform = platform_scene.instantiate()
			add_child(platform)
			
			# Calculate position with zigzag pattern
			var base_x = spawn_bounds.position.x + (spawn_bounds.size.x / 2) + offset
			
			# Add small random offset for variety
			var random_offset = Vector2(
				randf_range(-20, 20),  # Small X variation
				randf_range(-10, 10)   # Small Y variation
			)
			
			platform.position = Vector2(base_x, row_y) + random_offset
			spawned_positions.append(platform.position)
