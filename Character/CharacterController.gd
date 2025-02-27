extends CharacterBody2D

const UPWARDS = Vector2.UP

@export var speed = 0.0
@export var acceleration = 0.0
@export var jump_strength = 0.0
@export var gravity = 0.0
@export var friction = 0.0
@export var jump_cancel_modifier = 0.0
@export var scale_effect = 0.0

@onready var coyote_timer = $CoyoteTimer
@onready var animations = $PlayerAnimations
@onready var interacting = false
@onready var can_interact = false
@onready var facing_right = true
@onready var current_pos = position

func _physics_process(delta):
	var can_jump = is_on_floor() or !coyote_timer.is_stopped()
	var horizontal_dir = Input.get_axis("MoveLeft", "MoveRight")
	if horizontal_dir:
		if is_on_floor():
			velocity = velocity.move_toward(Vector2(horizontal_dir, 0) * speed, acceleration * delta)
		else:
			velocity.x = horizontal_dir * speed
	else:
		if is_on_floor():
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		else:
			velocity.x = horizontal_dir * speed
			
	velocity.y += gravity * delta
	
	var is_falling = velocity.y > 0 and not is_on_floor()
	var is_jumping = Input.is_action_just_pressed("Jump") and can_jump
	var is_jump_cancelled = Input.is_action_just_released("Jump") and velocity.y < 0.0
	var is_idle = is_on_floor() and is_zero_approx(velocity.x)
	var is_running = is_on_floor() and not is_zero_approx(velocity.x)
	
	if is_jumping:
		velocity.y = -jump_strength
	elif  is_jump_cancelled:
		velocity.y += jump_cancel_modifier
	
	var was_on_floor = is_on_floor()
	
	if horizontal_dir > 0 and !facing_right:
		_flip()
	elif horizontal_dir < 0 and facing_right:
		_flip()
		
	current_pos = position
	
	move_and_slide()
	
	if (was_on_floor and !is_on_floor() and not Input.is_action_just_pressed("Jump")):
		coyote_timer.start()
		
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		if col.get_collider() is RigidBody2D:
			if ((current_pos.y - position.y) > 12 and !is_falling):
				velocity.y = -scale_effect

func _input(event):
	if event.is_action_pressed("Kick"):
		animations.play("Kick")
		
func _flip():
	var current_scale = scale
	current_scale.x *= -1
	scale = current_scale
	facing_right = !facing_right
	  
	
