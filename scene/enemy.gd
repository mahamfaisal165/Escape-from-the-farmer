extends CharacterBody2D

@export var speed: float = 80.0
@export var jump_velocity: float = -450.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast: RayCast2D = $RayCast2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var player: Node2D = null
var is_stunned: bool = false
var stun_timer: float = 0.0
var jump_cooldown: float = 0.0

# --- SEQUENTIAL SPAWN VARIABLES ---
var spawn_points: Array = []
var current_spawn_index: int = 0
var is_respawning: bool = false

@export var fall_y_limit: float = 350.0

func _ready() -> void:
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")
	
	# Find only Area2D nodes in the "spawn_points" group
	spawn_points.clear()
	for node in get_tree().get_nodes_in_group("spawn_points"):
		if node is Area2D:
			spawn_points.append(node)
			
	# Sort them by their X position so they go sequentially across the level left-to-right!
	spawn_points.sort_custom(func(a, b): return a.global_position.x < b.global_position.x)

func _physics_process(delta: float) -> void:
	if is_respawning:
		return

	if not player or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")

	# 1. Check if Enemy fell into a pit
	if global_position.y > fall_y_limit:
		start_respawn_sequence()
		return

	# 2. Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	if jump_cooldown > 0.0:
		jump_cooldown -= delta

	# 3. Handle Stun
	if is_stunned:
		stun_timer -= delta
		if stun_timer <= 0.0:
			is_stunned = false
		velocity.x = 0
		move_and_slide()
		return

	# 4. Follow Player
	if player and is_instance_valid(player):
		var direction_to_player = player.global_position.x - global_position.x
		var move_dir = sign(direction_to_player)

		if abs(direction_to_player) > 10.0:
			velocity.x = move_dir * speed
			animated_sprite.flip_h = move_dir < 0
			ray_cast.position.x = move_dir * 25.0
		else:
			velocity.x = 0

		# 5. Jump Check
		if is_on_floor() and jump_cooldown <= 0.0:
			var is_hitting_wall = is_on_wall()
			if is_hitting_wall or (player.global_position.y < global_position.y - 40):
				velocity.y = jump_velocity
				jump_cooldown = 0.3

		# 6. Animations
		if velocity.x != 0:
			animated_sprite.play("walking")
		else:
			animated_sprite.play("idle")

	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		if is_on_floor():
			animated_sprite.play("idle")

	move_and_slide()

	# 7. Check Player Collision
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and (collider == player or collider.is_in_group("player")):
			reload_game()

func start_respawn_sequence() -> void:
	if is_respawning:
		return
	is_respawning = true
	velocity = Vector2.ZERO
	hide()

	# Wait for 1.5 seconds
	await get_tree().create_timer(1.5).timeout

	# Respawn at the current spawn point index
	if spawn_points.size() > 0:
		var target_spawn = spawn_points[current_spawn_index]
		if is_instance_valid(target_spawn) and target_spawn is Area2D:
			global_position = target_spawn.global_position
		
		# Advance to the next spawn point for next time
		current_spawn_index = (current_spawn_index + 1) % spawn_points.size()

	show()
	is_respawning = false

func stun() -> void:
	is_stunned = true
	stun_timer = 3.0
	velocity.x = 0
	animated_sprite.play("faint")

func reload_game() -> void:
	if is_inside_tree() and get_tree() != null:
		get_tree().call_deferred("reload_current_scene")
