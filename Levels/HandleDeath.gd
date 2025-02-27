extends Node2D

@export var player: RigidBody2D

@onready var respawn_point = $PlayerStart


func handle_danger(body):
	if body.is_in_group("Player"):
		body.handle_danger(respawn_point.global_position)
