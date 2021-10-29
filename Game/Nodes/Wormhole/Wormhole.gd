extends Node2D 

export (String) var scene_name

export (String) var location_name

var opacity

func _ready():
	connect("body_entered", self, "_on_body_entered")
	
func _on_body_entered(body):
	if body is KinematicBody:
		self.get_parent().teleport(scene_name, location_name)
		
