extends RigidBody2D

signal scale_complete(scale_diff, body)

@export var initial_scale = Vector2(1.47, 1.47)
@export var kick_force = 0.0
@export var scale_amount = 0.0
@export var interpolation = .2
@export var max_scale = 3.0
@export var min_scale = 1.0
@export var weight_mulitplier = 0.0
@export var bouncieness = 0.0
@export var connected_boxes: Array[RigidBody2D]

@onready var collider = $BoxCollider
@onready var scale_timer = $ScaleTimer
@onready var max_up = $CheckUp
@onready var max_left = $CheckLeft
@onready var max_right = $CheckRight
@onready var box_anim = $AnimateBox
@onready var start = false
@onready var start_scale = collider.scale

var kickable = true
var scaling = false
var scale_diff = 0
var scale_constraint = 0

func _ready():
	collider.scale = initial_scale

func _physics_process(delta):
	mass = collider.scale.x * weight_mulitplier
	if max_up.is_colliding():
		var collision_point = max_up.get_collision_point()
		var origin = max_up.global_transform.origin
		var distance = origin.distance_to(collision_point)
	else:
		scale_constraint = 0

func _on_collision_box_box_kicked(side):
	if (kickable and mass < 2):
		apply_impulse(Vector2(kick_force * side, 0))

func _scale_up():
	_scale_box(true)
	scale_partners(false)
		
func _scale_down():
	_scale_box(false)
	scale_partners(true)
		
func scale_partners(up):
	for connected_box in connected_boxes:
		connected_box._scale_box(up)

func _scale_box(up: bool):
	if up:
		var current_scale = collider.scale
		if (current_scale < Vector2(max_scale, max_scale)):
			if scale_constraint > 0:
				if (current_scale < Vector2(scale_constraint, scale_constraint)):
					if scale_timer.is_stopped():
						scale_timer.start()
						start_scale = collider.scale
					collider.scale = lerp(current_scale, Vector2(current_scale.x + scale_amount, current_scale.y + scale_amount), interpolation)
			else:
				if scale_timer.is_stopped():
					scale_timer.start()
					start_scale = collider.scale
				collider.scale = lerp(current_scale, Vector2(current_scale.x + scale_amount, current_scale.y + scale_amount), interpolation)
	else:
		var current_scale = collider.scale
		if (current_scale > Vector2(min_scale, min_scale)):
			scale_timer.stop()
			start_scale = collider.scale
			scale_diff = 0
			collider.scale = lerp(current_scale, Vector2(current_scale.x - scale_amount, current_scale.y - scale_amount), interpolation)

func _on_mouse_control_scale_up(looking_at):
	if (looking_at):
		if looking_at.collider == self:
			_scale_up()

func _on_mouse_control_scale_down(looking_at):
	if (looking_at):
		if looking_at.collider == self:
			_scale_down()

func _on_timer_timeout():
	scale_diff = collider.scale - start_scale
	start_scale = collider.scale
	scale_complete.emit(scale_diff, self)

func get_scale_diff():
	return scale_diff
	
func animate(raycast):
	if raycast:
		if raycast.collider == self:
			play_selected("Selected")
			animate_partners()
		if raycast.collider.is_in_group("Scalable"):
			return
	box_anim.play("RESET")

func animate_partners():
	for connected_box in connected_boxes:
		connected_box.play_selected("Connected")

func play_selected(type: String):
	box_anim.play(type)
