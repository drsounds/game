extends "res://Game/entities/Character.gd"
func _timeline_end():
	self.locked = false

func _timeline_start():
	self.locked = true

func use(node):
	self.locked = true
	var dialog = Dialogic.start('andy')
	get_parent().get_parent().get_parent().get_parent().add_child(dialog)# Declare member variables here. Examples:
	dialog.connect('timeline_end', self, "_timeline_end")
	dialog.connect('timeline_start', self, "_timeline_start")
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
