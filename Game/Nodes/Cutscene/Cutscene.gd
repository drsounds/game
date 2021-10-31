extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var cutscene

var scene

var cutscene_timer

var actors = {}
var events = []
var event_pos = 0

var target = null

var current_event = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func load_cutscene(name):
	var file = File.new()
	var path = "res://Cutscenes/" + name + ".json"
	if file.fileExists(path, File.READ):
		file.open(path, File.READ)
		var data = parse_json(file.get_as_text())
		self.cutscene = data

func play():
	stop()
	cutscene_timer = Timer.new()
	cutscene_timer.connect("timeout", self, "_tick")
	
	load_actors()
	
	self.events = self.cutscene['events']
	
	self.cutscene_timer.start()
	
	
func _tick():
	_process_next()

func load_actors():
	for actor_id in self.cutscene['actors'].keys():
		var actor_data = self.cutscene['actors'][actor_id]
		var ActorScene = load(actor_data['entity'])
		var actor = ActorScene.instantiate()
		self.actors[actor_id] = actor

func _process_events(events):
	for event in events:
		event['completed'] = _process_event(event)

func _process_event(event):
	current_event = null
	var is_completed = true
	for sub_event in event['actions']:
		if not sub_event['completed']:
			sub_event['completed'] = _process_sub_event(sub_event)
			if not sub_event['completed']:
				is_completed = false
				current_event = event
	return is_completed
	
func _add_actor_sub_event(sub_event):
	var actor_id = sub_event['actor']
	if not actor_id in self.actors:
		return
	var actor = self.actors[actor_id]
	var position_id = sub_event['position']
	var position = self.scene.get_node('Spawn_' + position_id)
	self.scene.add_child(actor)
	actor.global_position.x  = position.global_position.x
	actor.global_position.y = position.global_position.y
	return true

func _goto_actor_sub_event(sub_event):
	var actor_id = sub_event['actor']
	if not actor_id in self.actors:
		return
	var actor = self.actors[actor_id]
	if not actor:
		print("Actor is null")
		return false
	var position_id = sub_event['position']
	var position = self.scene.get_node('Spawn_' + position_id)
	self.target = position
	
	actor.connect('arrived', self, '_walked_to')
	actor.walk_event = sub_event
	actor.walk_to(position)
	
	return sub_event['completed']
	


func _process_sub_event(sub_event):
	if sub_event['action'] == "add":
		_add_actor_sub_event(sub_event)
	if sub_event['action'] == 'goto':
		_goto_actor_sub_event(sub_event)

func _process_next():
	if self.events.count > event_pos:
		var event = self.events[event_pos]
		
		_process_events(event)
	
	
func stop():
	if cutscene_timer:
		cutscene_timer.stop()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
