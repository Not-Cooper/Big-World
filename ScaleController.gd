extends Node2D

signal scaled(scale_diff, body)

var scalables

func _ready():
	scalables = get_children()
	for scalable in scalables:
		scalable.scale_complete.connect(_scale.bind())

func _scale(scale_diff, body):
	scaled.emit(scale_diff, body)


func _on_mouse_control_visible_box(raycast):
	for scalable in scalables:
		scalable.animate(raycast)
