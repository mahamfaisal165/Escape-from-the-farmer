extends Area2D

@onready var game_manager: Node = %"game manager"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var coin_sound: AudioStreamPlayer2D = $CoinSound  # Added audio reference

@export var coin_value: int = 1

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
		game_manager.add_point()

func collect(player_node: Node2D) -> void:
	# If player has a score collection method, update it
	if player_node.has_method("add_coins"):
		player_node.add_coins(coin_value)
	
	# Disable collision immediately so it can't be collected twice
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Play the sound effect
	if coin_sound:
		coin_sound.play()
	
	# Handle pickup animation or immediate hide + sound wait
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("pickup"):
		animated_sprite.play("pickup")
		await animated_sprite.animation_finished
	else:
		# Hide the sprite immediately if there's no pickup animation
		if animated_sprite:
			animated_sprite.hide()
	
	# Wait for the sound to finish playing before deleting the coin so it doesn't cut off
	if coin_sound and coin_sound.playing:
		await coin_sound.finished
		
	queue_free()
