extends RigidBody2D

@export var speed = 0.0
@export var acceleration = 0.0
@export var decceleration = 0.0
@export var velocityPow = 0.0
@export var jump_strength = 0.0
@export var jump_cancel_modifier = 0.0
@export var gravity_multiplier = 0.0
@export var fall_clamp = 0.0
@export var scale_effect = 0.0

@onready var launch_timer = $LaunchTimer
@onready var jump_buffer = $JumpBuffer
@onready var animations = $PlayerAnimations
@onready var ground_check1 = $CheckGrounded
@onready var ground_check2 = $CheckGrounded2
@onready var physics_check = $PhysicsCheck
@onready var character_sprite = $Sprite2D
@onready var kick_box = $Kick
@onready var kick_sound = $sfx_kick
@onready var jump_sound = $sfx_jump
@onready var current_gravity = gravity_scale
@onready var interacting = false
@onready var can_interact = false
@onready var facing_right = true
@onready var current_pos = position
@onready var grounded = false
@onready var can_jump = false
@onready var is_falling = false
@onready var is_jumping = false
@onready var is_jump_cancelled = false
@onready var is_idle = false
@onready var is_running = false
@onready var has_jumped = false
@onready var horizontal_dir
@onready var can_control = true

var interacting_with_object = false
var physics_object
var launched = false
var buffered_jump = false

func _physics_process(delta):
	if !can_control:
		return
	
	horizontal_dir = Input.get_axis("MoveLeft", "MoveRight")
	grounded = (ground_check1.is_colliding() or ground_check2.is_colliding()) and !is_jumping
	interacting_with_object = physics_check.is_colliding()
	physics_object = physics_check.get_collider()
	can_jump = grounded and not launched
	is_falling = linear_velocity.y > 0 and not grounded
	is_jumping = Input.is_action_just_pressed("Jump") and can_jump
	is_jump_cancelled = Input.is_action_just_released("Jump") and linear_velocity.y < 0.0
	is_idle = grounded and is_zero_approx(linear_velocity.x)
	is_running = grounded and not is_zero_approx(linear_velocity.x)
		
	if horizontal_dir > 0 and !facing_right:
		_flip()
	elif horizontal_dir < 0 and facing_right:
		_flip()
		
	if grounded and launch_timer.is_stopped():
		launched = false
		
	if Input.is_action_just_pressed("Jump") and !is_jumping:
		buffered_jump = true
		jump_buffer.start()
		
	_run()
	_calculate_jump()
	_calculate_gravity()

func _run():
	var target_speed = horizontal_dir * speed
	var speed_dff = target_speed - linear_velocity.x
	var accelrate;
	if (abs(target_speed) > 0.1):
		animations.play("RunCycle")
		accelrate = acceleration
	else:
		accelrate = decceleration
	var movement = pow(abs(speed_dff) * accelrate, velocityPow) * sign(speed_dff)
	apply_force(movement * Vector2.RIGHT)
	
func _calculate_jump():
	if is_jumping:
		apply_force(Vector2(linear_velocity.x, -jump_strength))
		buffered_jump = false
		animations.play("Jump")
		jump_sound.play()
		jump_particles()
	elif buffered_jump and grounded:
		apply_force(Vector2(linear_velocity.x, -jump_strength))
		buffered_jump = false
		animations.play("Jump")
		jump_sound.play()
		jump_particles()
	if is_jump_cancelled:
		apply_central_impulse((Vector2.DOWN * linear_velocity.y * (1 - jump_cancel_modifier)))

func _calculate_gravity():
	if linear_velocity.y > 0.1:
		gravity_scale = gravity_multiplier * gravity_scale
		animations.play("Fall")
	else:
		gravity_scale = current_gravity
	
	if linear_velocity.y > fall_clamp:
		var clamped = linear_velocity.clamp(Vector2(speed*horizontal_dir, 0), Vector2(speed, fall_clamp))
		linear_velocity = clamped

func _flip():
	var current_scale = kick_box.scale
	current_scale.x *= -1
	character_sprite.flip_h = 1 if facing_right else 0
	kick_box.scale = current_scale
	facing_right = !facing_right

func _on_scale_controller_scaled(scale_diff, body):
	if physics_object == body:
		apply_central_impulse(Vector2(0, -(scale_diff.y * body.bouncieness)))
		launch_timer.start()
		launched = true
		animations.play("Jump")
		jump_sound.play()
		jump_particles()

func _on_jump_buffer_timeout():
	buffered_jump = false


func handle_danger(spawn_position):
	can_control = false
	visible = false
	
	await get_tree().create_timer(.3).timeout
	reset_player(spawn_position)
	
func reset_player(spawn_position):
	position = spawn_position
	visible = true
	can_control = true
	
func jump_particles():
	var inst = load("res://Art/Character/jump_particle.tscn").instantiate()
	add_child(inst)
	inst.top_level = true
	inst.global_position = Vector2(position.x, position.y+15)
	
func _input(event):
	if event.is_action_pressed("ResetLevel"):
		get_tree().reload_current_scene()
