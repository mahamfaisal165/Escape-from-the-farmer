extends CharacterBody2D

# Movement & Jump parameters
@export var speed: float = 110.0
@export var jump_velocity: float = -380.0
@export var player: Node2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Faint State
var is_fainting: bool = false

@onready var sprite = $AnimatedSprite2D
@onready var raycast = $RayCast2D
@onready var hitbox = $Hitbox

func _ready():
	if raycast:
		raycast.enabled = true
		
	# Connect the Hitbox body_entered signal via code to detect the player
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# If fainting, stop horizontal movement and skip chase logic
	if is_fainting:
		velocity.x = move_toward(velocity.x, 0, speed)
		move_and_slide()
		return

	# Auto-find player if not assigned
	if not player:
		player = get_tree().get_first_node_in_group("player")

	if player:
		var direction = sign(player.global_position.x - global_position.x)
		velocity.x = direction * speed

		# Update RayCast direction based on movement
		if direction != 0:
			sprite.flip_h = (direction < 0)
			raycast.target_position.x = direction * 25.0 

		# Auto-Jump Obby Logic
		var obstacle_ahead = raycast.is_colliding()
		var player_is_higher = (player.global_position.y < global_position.y - 30.0)

		if is_on_floor() and (obstacle_ahead or player_is_higher):
			velocity.y = jump_velocity

	move_and_slide()

# Function called when the farmer touches the player
func _on_hitbox_body_entered(body):
	# If the farmer is not fainting and touches the player, restart the game/level
	if not is_fainting and body.is_in_group("player"):
		if body.has_method("die"):
			body.die()
		else:
			# Quick fallback: restarts the current scene instantly
			get_tree().reload_current_scene()

# Function called when poop hits the enemy
func hit_by_poop():
	if is_fainting:
		return
		
	is_fainting = true
	velocity.x = 0
	
	if sprite.sprite_frames.has_animation("faint"):
		sprite.play("faint")
	else:
		sprite.modulate = Color(0.5, 0.5, 0.5)

	# Wait for 3 seconds of faint time
	await get_tree().create_timer(3.0).timeout

	sprite.modulate = Color(1, 1, 1)
	is_fainting = false
