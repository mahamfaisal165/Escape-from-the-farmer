extends Area2D

@export var coin_value: int = 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Connect collision signal
	body_entered.connect(_on_body_entered)
	
	# Play default idle/spin animation if available
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")

func _on_body_entered(body: Node2D) -> void:
	# Check if player collected the coin
	if body.is_in_group("player") or body.name == "player":
		collect(body)

func collect(player_node: Node2D) -> void:
	# If player has a score collection method, update it
	if player_node.has_method("add_coins"):
		player_node.add_coins(coin_value)
	
	# Optional: You can play a pickup animation or sound before deleting
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("pickup"):
		# Disable collision so it can't be collected twice while playing pickup animation
		$CollisionShape2D.set_deferred("disabled", true)
		animated_sprite.play("pickup")
		await animated_sprite.animation_finished
		queue_free()
	else:
		queue_free()
