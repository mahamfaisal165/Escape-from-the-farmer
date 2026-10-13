extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var poop_scene: PackedScene = preload("res://scene/poop.tscn")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- COIN VARIABLE ---
var coins_collected: int = 0

# --- TRAP VARIABLES ---
var is_trapped: bool = false
var escape_jump_count: int = 0
const JUMPS_TO_ESCAPE: int = 2
var current_cage: Node2D = null

func _ready() -> void:
	add_to_group("player")

# --- COIN COLLECTION METHOD ---
func add_coins(amount: int) -> void:
	coins_collected += amount
	print("Coins collected: ", coins_collected)
	# (Optional: Update UI/HUD here if you have a score label)

# Call this from the cage when trapped
func get_trapped(cage_node: Node2D) -> void:
	if is_trapped:
		return
	is_trapped = true
	escape_jump_count = 0
	current_cage = cage_node
	velocity = Vector2.ZERO
	# Center player inside the cage
	global_position = cage_node.global_position

func _physics_process(delta: float) -> void:
	# --- TRAP ESCAPE MECHANIC ---
	if is_trapped:
		velocity = Vector2.ZERO
		
		# Count jump key presses to break free
		if Input.is_action_just_pressed("ui_accept"):
			escape_jump_count += 1
			animated_sprite.play("jump")
			
			if escape_jump_count >= JUMPS_TO_ESCAPE:
				is_trapped = false
				
				# Tell the cage to play its open animation
				if current_cage and is_instance_valid(current_cage) and current_cage.has_method("open_cage"):
					current_cage.open_cage()
				
				current_cage = null
				
				# Perform escape jump upwards
				velocity.y = jump_velocity
		
		move_and_slide()
		return # Stop normal movement while trapped
	# -----------------------------

	# --- NORMAL MOVEMENT LOGIC ---
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

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

	if not is_on_floor() and velocity.y < 0:
		animated_sprite.play("jump")

	move_and_slide()

	if Input.is_action_just_pressed("throw"):
		throw_poop()

func throw_poop() -> void:
	if not poop_scene:
		return
	
	var poop_instance = poop_scene.instantiate()
	poop_instance.global_position = global_position
	
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	
	if poop_instance.has_method("setup"):
		poop_instance.setup(direction)
	
	get_tree().current_scene.add_child(poop_instance)
