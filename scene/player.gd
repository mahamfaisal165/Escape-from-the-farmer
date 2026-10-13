extends CharacterBody2D

# Movement Parameters
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Add the gravity when in the air
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get horizontal direction: -1 (left), 1 (right), or 0 (idle)
	var direction = Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Update Sprite Animations
	update_animations(direction)

	# Apply physics movement
	move_and_slide()

func update_animations(direction):
	if not is_on_floor():
		# Play jump animation when in mid-air
		animated_sprite.play("jump")
	elif direction < 0:
		# Moving left
		animated_sprite.play("left")
	elif direction > 0:
		# Moving right
		animated_sprite.play("right")
	else:
		# Standing still on ground
		animated_sprite.play("idle")
