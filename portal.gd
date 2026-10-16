extends Area2D

# Export the path to the next scene so you can select it in the Inspector
@export_file("*.tscn") var next_scene_path: String

# The name of the node group your eggs/coins belong to (e.g., "eggs", "coins")
@export var egg_group_name: String = "eggs"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var player_in_range: bool = false
var is_open: bool = false
var is_transitioning: bool = false

func _ready() -> void:
	# Ensure the portal starts closed
	animated_sprite.play("close")

func _process(_delta: float) -> void:
	# 1. Check if all eggs are collected to open the portal
	if not is_open:
		# Counts remaining nodes in the "eggs" group
		var remaining_eggs: int = get_tree().get_nodes_in_group(egg_group_name).size()
		if remaining_eggs == 0:
			is_open = true
			animated_sprite.play("open")

	# 2. Check if player is standing in an open portal and presses 'E'
	if is_open and player_in_range and not is_transitioning and Input.is_key_pressed(KEY_E):
		is_transitioning = true
		
		# Change to the next scene
		if next_scene_path != "":
			get_tree().change_scene_to_file(next_scene_path)
		else:
			print("No next scene path set in the Inspector!")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		player_in_range = false
