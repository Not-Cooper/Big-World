extends Node2D

signal opened()
signal closed()

@onready var open_animation = $MoveWall
@onready var door_opened = false

func on_open():
	if !door_opened:
		open_animation.play("Open")
		opened.emit()
		door_opened = true

func on_close():
	if door_opened:
		open_animation.play("Close")
		closed.emit()
		door_opened = false
