extends Node2D

signal scale_up(looking_at)
signal scale_down(looking_at)

signal visible_box(raycast)

@export var vision_start: RigidBody2D

@onready var mouse_position

var looking_at

func _physics_process(delta):
	mouse_position = get_global_mouse_position()
	position = mouse_position
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(vision_start.position, Vector2(mouse_position.x+8, mouse_position.y+8), 1)
	looking_at = space_state.intersect_ray(query)
	visible_box.emit(looking_at)

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				scale_up.emit(looking_at)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				scale_down.emit(looking_at)
