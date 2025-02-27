extends Node2D

@onready var played = false
@onready var animate_text = $PlayText

func _on_scale_control_scaled(scale_diff, body):
	if !played:
		animate_text.play("Show Text")
		played = true
