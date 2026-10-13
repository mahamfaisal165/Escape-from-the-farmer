extends CharacterBody2D

@export var speed: float = 140.0
@export var jump_velocity: float = -450.0 # Increased jump height/reach

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast: RayCast2D = $RayCast2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var player: Node2D = null
var is_stunned: bool = false
var stun_timer: float = 0.0

# Prevents rapid jump re-triggering
var jump_cooldown: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	# 1. Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	if jump_cooldown > 0.0:
		jump_cooldown -= delta

	# 2. Handle Stun
	if is_stunned:
		stun_timer -= delta
		if stun_timer <= 0.0:
			is_stunned = false
		velocity.x = 0
		move_and_slide()
		return

	# 3. Follow Player
	if player and is_instance_valid(player):
		var direction_to_player = player.global_position.x - global_position.x
		var move_dir = sign(direction_to_player)

		if abs(direction_to_player) > 10.0:
			velocity.x = move_dir * speed
			animated_sprite.flip_h = move_dir < 0
			
			# Push the RayCast well out in front (25px) so it detects the edge in advance
			ray_cast.position.x = move_dir * 25.0
		else:
			velocity.x = 0

		# 4. Jump Check (Must be on floor and off cooldown)
		if is_on_floor() and jump_cooldown <= 0.0:
			var is_at_edge = not ray_cast.is_colliding()
			var is_hitting_wall = is_on_wall()
			
			# Trigger Jump when near an edge or wall
			if is_at_edge or is_hitting_wall or (player.global_position.y < global_position.y - 40):
				velocity.y = jump_velocity
				jump_cooldown = 0.3 # Cooldown to avoid multi-jumping

		# 5. Animations
		if velocity.x != 0:
			animated_sprite.play("walking")
		else:
			animated_sprite.play("idle")

	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		if is_on_floor():
			animated_sprite.play("idle")

	move_and_slide()

	# 6. Check Player Collision
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and (collider == player or collider.is_in_group("player")):
			reload_game()

func stun() -> void:
	is_stunned = true
	stun_timer = 3.0
	velocity.x = 0
	animated_sprite.play("faint")

func reload_game() -> void:
	if is_inside_tree() and get_tree() != null:
		get_tree().call_deferred("reload_current_scene")
