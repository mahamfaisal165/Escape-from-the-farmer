extends Node

@onready var score_label: Label = $"score label"

var score: int = 0

func add_point() -> void:
	score += 1
	score_label.text = "Score: " + str(score)
