extends Node2D

signal button_pressed()
signal button_unpressed()

@onready var button_anim = $ButtonAnimation
@onready var pressed = false
@onready var door_closed = true

func _on_area_2d_body_entered(body):
	if body.is_in_group("CanInteract") and not pressed:
		button_anim.play("Pressed")
		pressed = true
		if door_closed:
			button_pressed.emit()

func _on_area_2d_body_exited(body):
	if body.is_in_group("CanInteract") and pressed:
		button_anim.play("UnPressed")
		pressed = false
		if !door_closed:
			button_unpressed.emit()

func connected_closed():
	door_closed = true

func connected_opened():
	door_closed = false
