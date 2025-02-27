extends Node2D

@onready var kick = $KickPlayer
@onready var kick_sound = $"../sfx_kick"

func _input(event):
	if event.is_action_pressed("Kick"):
		kick.play("Kick")
		kick_sound.play()
