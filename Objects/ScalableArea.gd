extends Area2D

signal scalable(can_scale)

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("area_entered", _on_area_entered.bind())
	connect("area_exited", _on_area_exit.bind())

func _on_area_entered(hitbox):
	if hitbox.name == "MouseArea":
		scalable.emit(true)

func _on_area_exit(hitbox):
	if hitbox.name == "MouseArea":
		scalable.emit(false)
