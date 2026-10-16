extends Area2D

# Export the path to the next scene so you can select it in the Inspector
@export_file("*.tscn") var next_scene_path: String

# The exact group name your collectible items belong to (e.g., "eggs")
@export var egg_group_name: String = "eggs"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var portal_sound: AudioStreamPlayer2D = $PortalSound

var is_open: bool = false
var is_transitioning: bool = false

func _ready() -> void:
	# Ensure the portal starts closed
	animated_sprite.play("close")

func _process(_delta: float) -> void:
	# 1. Check if all eggs/collectibles are collected to open the portal
	if not is_open:
		var remaining_items: int = get_tree().get_nodes_in_group(egg_group_name).size()
		
		# Once all items in the group are collected (reaches 0), open the portal
		if remaining_items == 0:
			is_open = true
			animated_sprite.play("open")

func _on_body_entered(body: Node2D) -> void:
	# 2. Check if the player touched the portal
	if body.is_in_group("player") or body.name == "player" or body.name == "Player":
		# Only trigger if the portal is fully open and we aren't already transitioning
		if is_open and not is_transitioning:
			is_transitioning = true
			
			# Play the sound globally so it finishes playing even after the scene changes
			if portal_sound and portal_sound.stream:
				var temp_sound = AudioStreamPlayer.new()
				temp_sound.stream = portal_sound.stream
				get_tree().root.add_child(temp_sound)
				temp_sound.play()
				temp_sound.finished.connect(temp_sound.queue_free)
			
			# Instantly teleport to the next scene without any delay or await!
			if next_scene_path != "":
				get_tree().change_scene_to_file(next_scene_path)
			else:
				print("No next scene path set in the Inspector!")

func _on_body_exited(body: Node2D) -> void:
	pass
