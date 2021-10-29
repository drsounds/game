extends Node
class_name SceneManager

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var timer_in = Timer.new()
var timer_out = Timer.new()
var from_scene 
var to_scene
var player
var scene_name
var spawn_name

func teleport(scene_name, spawn_name):
	var player = null
	self.scene_name = scene_name
	self.spawn_name = spawn_name
	for scene in self.get_children():
		player = scene.get_node('Player')
		if player:
			self.player = player
			self.from_scene = scene
			fade_out_old_scene()
			return
	switch_scenes() 
	
	
func fade_out_old_scene():
	self.timeout.start()

	
func _timeout(): 
	self.from_scene.modulate.a -= 0.01
	if self.from_scene.modulate.a <= 0:
		self.timer_out.stop()
		switch_scenes()


func switch_scenes():
	if self.from_scene:
		self.from_scene.remove_child(player)
		self.remove_child(self.from_scene)
		
	if not self.player:
		var PlayerScene = load('res://Game/entities/Character.tscn')
		player = PlayerScene.instance()
		self.player = player
	
	var Scene = load('res://Game/Scenes/' + scene_name + '/' + scene_name + '.tscn')
	var scene = Scene.instance()
	scene.modulate.a = 0
	self.to_scene = scene
	self.add_child(scene)
	
	var spawn_node = scene.get_node('Spawn_' + spawn_name)
	scene.add_child(player)
	player.current = true
	
	player.global_position.x = spawn_node.global_position.x
	player.global_position.y = spawn_node.global_position.y
	
	fade_in_new_scene()

func fade_in_new_scene():
	self.timer_in.start()

func _timein():
	self.to_scene.modulate.a += 0.01
	if self.to_scene.modulate.a >= 1:
		self.timer_in.stop()
	
func _ready():
	timer_in.connect("timeout", self, "_timein")
	timer_out.connect("timeout", self, "_timeout")
	timer_in.wait_time = 0.01
	timer_out.wait_time = 0.01
	self.add_child(timer_in)
	self.add_child(timer_out)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
