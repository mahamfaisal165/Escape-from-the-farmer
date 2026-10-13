extends CharacterBody2D

@export var speed: float = 250.0
@export var jump_velocity: float = -400.0

# Get default gravity setting from Project Settings
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	# Add gravity when not on the ground
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get input direction (-1 for left, 1 for right, 0 for neutral)
	var direction := Input.get_axis("ui_left", "ui_right")

	# Apply left/right movement
	if direction != 0:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
