extends Area2D

# Timer to allow a brief pause before scene reload (so player can see they died)
@export var reload_delay: float = 0.5

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the player touched the kill zone
	if body.is_in_group("player") or body.name == "player":
		die(body)

func die(player_node: Node2D) -> void:
	# Optional: Disable player movement so they can't keep moving while dying
	if player_node.has_method("set_physics_process"):
		player_node.set_physics_process(false)
	
	# Wait for the reload delay
	if reload_delay > 0:
		await get_tree().create_timer(reload_delay).timeout
	
	# Reload current scene safely
	if is_inside_tree() and get_tree() != null:
		get_tree().call_deferred("reload_current_scene")
