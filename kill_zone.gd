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
	# Call the player's die() function so it plays the death sound!
	if player_node.has_method("die"):
		player_node.die()
	else:
		# Fallback if player doesn't have die()
		if player_node.has_method("set_physics_process"):
			player_node.set_physics_process(false)
		
		if reload_delay > 0:
			await get_tree().create_timer(reload_delay).timeout
		
		if is_inside_tree() and get_tree() != null:
			get_tree().call_deferred("reload_current_scene")
