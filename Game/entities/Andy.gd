extends "res://Game/entities/Character.gd"


func use(node):
	var dialog = Dialogic.start('andy')
	get_parent().get_parent().get_parent().get_parent().add_child(dialog)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
