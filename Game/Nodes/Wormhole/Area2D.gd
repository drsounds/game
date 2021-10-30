extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

 
func _ready():
	self.connect("body_entered", self, "_on_body_entered")
	
func _on_body_entered(body):
	if body is KinematicBody:
		self.get_parent().get_parent().teleport(get_parent().scene_name, get_parent().location_name)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
