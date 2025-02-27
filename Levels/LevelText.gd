extends Control

@onready var text_anim = $ShowExplanation
@onready var triggered = false

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player") and not triggered:
		text_anim.play("Show Text")
		triggered = true
