extends Area2D

@export var side = 0.0

signal box_kicked(side)

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("area_entered", _on_area_entered.bind())


func _on_area_entered(hitbox):
	if hitbox.name == "KickHitbox":
		box_kicked.emit(side)
