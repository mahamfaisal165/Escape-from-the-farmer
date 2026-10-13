extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var poop_scene: PackedScene = preload("res://scene/poop.tscn")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	# Add player to group so the enemy can find them easily
	add_to_group("player")

func _physics_process(delta: float) -> void:
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get horizontal movement direction (-1, 0, 1)
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * speed
		if direction < 0:
			animated_sprite.play("left")
		else:
			animated_sprite.play("right")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		if is_on_floor():
			animated_sprite.play("idle")

	# Play jump animation if airborne
	if not is_on_floor() and velocity.y < 0:
		animated_sprite.play("jump")

	move_and_slide()

	# Handle throwing poop on left-click ("throw" action)
	if Input.is_action_just_pressed("throw"):
		throw_poop()

func throw_poop() -> void:
	if not poop_scene:
		return
	
	var poop_instance = poop_scene.instantiate()
	poop_instance.global_position = global_position
	
	# Aim towards mouse cursor position
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	
	if poop_instance.has_method("setup"):
		poop_instance.setup(direction)
	
	# Add poop instance to the main game scene
	get_tree().current_scene.add_child(poop_instance)
