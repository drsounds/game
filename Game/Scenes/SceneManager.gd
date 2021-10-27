extends Node
class_name SceneManager

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func teleport(scene_name, spawn_name):
	var player = null
	for scene in self.get_children():
		player = scene.get_node('Player')
		if player:
			scene.remove_child(player)
		self.remove_child(scene)
		
	if not player:
		var PlayerScene = load('res://Game/entities/Character.tscn')
		player = PlayerScene.instance()
	
	var Scene = load('res://Game/Scenes/' + scene_name + '/' + scene_name + '.tscn')
	var scene = Scene.instance()
	self.add_child(scene)
	
	var spawn_node = scene.get_node('Spawn_' + spawn_name)
	scene.add_child(player)
	player.current = true
	
	player.global_position.x = spawn_node.global_position.x
	player.global_position.y = spawn_node.global_position.y

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
