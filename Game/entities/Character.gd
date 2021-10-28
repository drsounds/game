extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var _z = 0
var _z_velocity = 0

var jumping_over = null

var is_suspended = false

var _is_falling = false

export(float) var z setget set_z, get_z
export(float) var z_velocity setget set_z_velocity, get_z_velocity 
export(float) var z_gravity = 0.2
export(float) var x_velocity = 0
export(float) var y_velocity = 0
export (bool) var current setget set_is_current, get_is_current
export (bool) var is_bathing setget set_is_bathing, get_is_bathing
var _is_bathing = false
var is_jumping_down = false
var camera_pos_x = 0
var camera_pos_y = 0

var ROOM_WIDTH = 9
var ROOM_HEIGHT = 9

export(Resource) var item_a
export(Resource) var item_b

export(Resource) var use_script

var use_script_node

var locked = false

var current_collider

var items = {}

var start_scroll_x = 0
var end_scroll_x = 0
var start_scroll_y = 0
var end_scroll_y = 0
var scroll_x_velocity = 2
var scroll_y_velocity = 2

var scroll_x = 0
var scroll_y = 0

var is_scrolling_x = false
var is_scrolling_y = false

var fall_shrink = 10


func set_is_falling(value):
	self._is_falling = value
	

func scroll_scene_x(x):
	start_scroll_x = x
	if x > 0:
		end_scroll_x = x - get_viewport().get_size().x 
	else:
		end_scroll_x = x + get_viewport().get_size().x
	is_scrolling_x = true


func scroll_scene_y(y):
	start_scroll_y = y
	if y > 0:
		end_scroll_y = y - get_viewport().get_size().y 
	else:
		end_scroll_y = y + get_viewport().get_size().y 
	
	is_scrolling_y = true


func get_is_current():
	return $GameController.current


func set_is_current(value):
	$GameController.current = value
 

func set_is_bathing(value):
	self._is_bathing = value 
	$Node2D/CharacterBody.visible = !_is_bathing
	#$Gear.visible = is_bathing
	$Node2D/BathingSprite.visible = _is_bathing
	
func get_is_bathing():
	return self._is_bathing

func load_item(id):
	if not items.has(id):
		var item_scene = load('res://Game/Items/' + id + '/' + id + '.tscn')
		var item_node = item_scene.instance()
		items[id] = item_node
	return items[id]

func assign_gear(item):
	$Node2D/CharacterBody/Gear.add_child(item)
	
func unassign_gear(item):
	$Node2D/CharacterBody/Gear.remove_child(item)


func use(node):
	if self.use_script_node:
		self.use_script_node.run(node)

func assign_item(item, button):
	if button == 'a':
		if item_a:
			unassign_item(item_a) 
			item_a = item
			$CharacterBody.remove_child(item_a)	
			var image = item_a.get_node('Image')
			for item in $GameController/Node2D/HolderA.get_children():
				$GameController/Node2D/HolderA.remove_child(item)
			$GameController/Node2D/HolderA.add_child(image)
			$CharacterBody/Items.remove_child(item_a)
	$CharacterBody/Items.add_child(item)
	
	if button == 'b':
		if item_b:
			unassign_item(item_b) 
			item_b = item
			var image = item_a.get_node('Image')
			for item in $GameController/Node2D/HolderB.get_children():
				$GameController/Node2D/HolderB.remove_child(item)
			$GameController/Node2D/HolderB.add_child(image)
			$CharacterBody/Items.remove_child(item_b)
	$CharacterBody/Items.add_child(item)

func lock():
	locked = true

func unlock():
	locked = false

func unassign_item(item):
	remove_child(item)


func has_gear(gear_type):
	for gear in $Node2D/CharacterBody/Gear.get_children():
		if gear is Node2D:
			if gear.get_type() == gear_type:
				return true
	return false


func get_gear(gear_type):
	for gear in $Node2D/CharacterBody/Gear.get_children():
		if gear is Node2D:
			if gear.get_type() == gear_type:
				return gear
	return false


func teleport(scene_node, spawn):
	
	var current_scene = self.get_parent()
	if current_scene: 
		if self.get_parent():
			self.get_parent().remove_child(self)
		
		var scene_manager = current_scene.get_parent()
		scene_manager.remove_child(current_scene)
		scene_manager.add_child(scene_node)
	scene_node.add_child(self)
	
	
	var spawn_node = scene_node.get_node('Spawn_' + spawn)	
	self.global_position.x = spawn_node.global_position.x
	self.global_position.y = spawn_node.global_position.y


func _on_body_entered(body):
	if body.get_name().find('Wormhole') == 0:
		var packed_scene = body.scene
		var scene = packed_scene.instance()
		self.teleport(packed_scene, body.spawn_point)

func get_z():
	return _z

func jump_down(s, collider):
	if is_jumping_down:
		return
	var tile_y = 0
	var found_bottom = false
	var position_2 = position
	while not found_bottom:
		position_2.y += 16
		var tile_pos2 = collider.world_to_map(position_2)
		# Find the colliding tile position
		 
		var tile2_id = collider.get_cellv(tile_pos2)
		var shapes = collider.tile_set.tile_get_shapes(tile2_id)
		var found_collision = false
		for shape in shapes:
			var shape2 = shape["shape"]
			if shape2.is_class('ConvexPolygonShape2D'):
				found_collision = true
				tile_y += 16
		if not found_collision:
			found_bottom = true 
	z += tile_y * 10
	self.global_position.y += tile_y - 16
	is_jumping_down = true
	
	
func set_z(value):
	_z = value

func get_z_velocity():
	return _z_velocity
	
func respawn():
	var spawn_location = self.get_parent().get_node("Spawn_Start")
	
	self.global_position.x = spawn_location.global_position.x
	self.global_position.y = spawn_location.global_position.y
	
func set_z_velocity(value):
	_z_velocity = value

func _physics_process(delta):
	$GameController.position.x = -self.position.x + camera_pos_x + get_viewport().get_size().x / 2 + scroll_x
	$GameController.position.y = -self.position.y + camera_pos_y + get_viewport().get_size().y / 2 + scroll_y
	if is_scrolling_x:
		if abs(abs(start_scroll_x) - abs(end_scroll_x)) > 0:
			if start_scroll_x > end_scroll_x:
				start_scroll_x -= scroll_x_velocity
				scroll_x += scroll_x_velocity
				self.position.x += float(self.scroll_x_velocity) / 10.0
			else:
				start_scroll_x += scroll_x_velocity
				scroll_x -= scroll_x_velocity
				self.position.x -= float(self.scroll_x_velocity) / 10.0
		else:
			is_scrolling_x = false
			x_velocity = 0
		return
	elif is_scrolling_y:
		if abs(abs(start_scroll_y) - abs(end_scroll_y)) > 0:
			if start_scroll_y > end_scroll_y:
				start_scroll_y -= scroll_y_velocity
				scroll_y += scroll_y_velocity
				self.position.y += float(self.scroll_y_velocity) / 10.0
			else:
				start_scroll_y += scroll_y_velocity
				scroll_y -= scroll_y_velocity
				self.position.y -= float(self.scroll_y_velocity) / 10.0
		else:
			is_scrolling_y = false
			y_velocity = 0
		return
	else:
		scroll_x = self.global_position.x - fmod(self.global_position.x, self.get_viewport().get_size().x) 
		scroll_y = self.global_position.y - fmod(self.global_position.y, self.get_viewport().get_size().y)
		
	$GameController.position.x = -self.position.x + camera_pos_x + get_viewport().get_size().x / 2 + scroll_x
	$GameController.position.y = -self.position.y + camera_pos_y + get_viewport().get_size().y / 2 + scroll_y
	
	var tile_map = self.get_parent().get_node("TileMap")
	if tile_map:
		var tile_pos = tile_map.world_to_map(position)
		# Find the colliding tile position 
		# Get the tile id 
		var tile_id = tile_map.get_cellv(tile_pos)
		var tile_name = tile_map.tile_set.tile_get_name(tile_id)
		if z > 0:
			if tile_name == "Aqua":
				set_is_bathing(true)
			else:
				set_is_bathing(false)
				
			if tile_name == "Pit":
				set_is_falling(true)
			
	
	if _is_falling:
		fall_shrink -= 0.01
		if fall_shrink >= 0 and $Node2D.scale.y >= 0:
			$Node2D.scale.x -= float(fall_shrink) / 10000
			$Node2D.scale.y -= float(fall_shrink) / 10000
		else:
			fall_shrink = 10
			_is_falling = false
			$Node2D.scale.x = 0.1
			$Node2D.scale.y = 0.1
			self.respawn()

	if _z_velocity > -10:
		_z_velocity -= z_gravity
	if has_gear('flySuit') and get_gear('flySuit').is_suspended:
		if z < 60:
			
			if _z_velocity < 0:
				_z_velocity = abs(_z_velocity)*0.8
		if z > 110:
			_z_velocity *= abs(_z_velocity) * -0.8
	z += _z_velocity
	if z <= 0:
		z = 0
		z_velocity = 0 
		jumping_over = null
		is_jumping_down = false
	
	if has_gear('flySuit'):
		if _z_velocity > 0:
			if get_gear('flySuit').transform.origin.y > -10:
				get_gear('flySuit').transform.origin.y -= 1 
			if get_gear('flySuit').scale.y < 1.01:
				get_gear('flySuit').scale.y += 0.1 
		if z == 0:
			if get_gear('flySuit').transform.origin.y < -0.6:
				get_gear('flySuit').transform.origin.y += 0.6
			if get_gear('flySuit').scale.y > 1:
				get_gear('flySuit').scale.y -= 0.1
				
	$Node2D/CharacterBody.transform.origin.y = -z
	if jumping_over:
		self.global_position.x += jumping_over.position.x
		self.global_position.y += jumping_over.position.y	
	else:
		move_and_slide(Vector2(x_velocity * 100, y_velocity * 100))
		 
		self.current_collider = null
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision and collision.collider:
				var collider = collision.collider
				self.current_collider = collider
				if collider.get_name().find('Wormhole') == 0:
					var packed_scene = load('res://Game/Scenes/' + collider.scene + '/' + collider.scene + '.tscn')
					var scene = packed_scene.instance()
					self.teleport(scene, collider.spawn_point)
				if collider is TileMap:
					var tile_pos = collision.collider.world_to_map(position)
					# Find the colliding tile position
					tile_pos -= collision.normal
					# Get the tile id 
					var tile_id = collider.get_cellv(tile_pos)
					var tile_name =collider.tile_set.tile_get_name(tile_id)
					if tile_name == "tileset.png 2":
						if self.x_velocity > 0:
							jump()
							jump_over(0.5, 0, .5, 0)
					if tile_name == "tileset.png 3":
						if self.x_velocity < 0:
							jump()
							jump_over(-0.5, 0, .5, 0)
					if tile_name == "tileset.png 5":
						if self.y_velocity > 0:
							jump_down(self, collider)		
					if tile_name == "tileset.png 9":
						if self.y_velocity < 0:
							jump()
							jump_over(0, -0.5, 0, -0.5)					
						
					"""
					var tile_pos = collider.world_to_map(position)		
					print(tile_pos)
					var rect  = collider.get_cell_autotile_coord(tile_pos.x, tile_pos.y)
					print(rect)
					if rect.x == 6 and rect.y == 2:
						is_bathing = true
					else:
						is_bathing = false
					if rect.x == 4 and rect.y == 0:
						if self.x_velocity < 0:
							jump()
							jump_over(-1, 0, -1, 0)
					if rect.x == 1 and rect.y == 1:
						if self.x_velocity > 0:
							jump()
							jump_over(1, 0, 1, 0)
							
					if rect.x == 1 and rect.y == 2:
						if self.y_velocity < 0:
							jump()
							jump_over(0, -1, 0, -1)
					
					if rect.x == 2 and rect.y == 2:
						if self.y_velocity > 0:
							jump()
							jump_over(0, 1, 0, 1)
					"""
	
	if floor(fmod(self.position.x, get_viewport().get_size().x)) == 0 and x_velocity > 0:
		scroll_scene_x(get_viewport().get_size().x)
	if floor(fmod(self.position.y, get_viewport().get_size().y)) == 0 and y_velocity > 0:
		scroll_scene_y(get_viewport().get_size().y)	
	if floor(fmod(self.position.x, get_viewport().get_size().x)) == 0 and x_velocity < 0:
		scroll_scene_x(-get_viewport().get_size().x)
	if floor(fmod(self.position.y, get_viewport().get_size().y)) == 0 and y_velocity < 0:
		scroll_scene_y(-get_viewport().get_size().y)	 

func jump_over(x_velocity, y_velocity, x_end, y_end):
	jumping_over = Rect2(x_velocity, y_velocity, x_end, y_end)
	z_velocity = 12

func _process(delta):
	y_velocity = 0
	x_velocity = 0
	if is_suspended:
		jump()
	if item_a:
		item_a.process_item()
	if item_b:
		item_b.process_item()
	if get_is_current() and not locked:
		if Input.is_action_just_pressed('ui_s'):
			if has_gear('flySuit'):	 
				is_suspended = !is_suspended 
		if Input.is_action_pressed('ui_a'):
			if current_collider and current_collider.has_method('use'):
				current_collider.use(self)
			elif item_a:
				item_a.use()
				
		if Input.is_action_pressed('ui_b'):
			if item_b:
				item_b.use()
		if Input.is_action_pressed('ui_up'):
			y_velocity = -0.3
		if Input.is_action_pressed('ui_down'):
			y_velocity = 0.3
		if Input.is_action_pressed('ui_left'):
			x_velocity = -0.3
		if Input.is_action_pressed('ui_right'):
			x_velocity = 0.3
		if Input.is_action_pressed('jump'):
			jump()
		if Input.is_action_just_released("ui_up"):
			y_velocity -= y_velocity
		if Input.is_action_just_released('ui_down'):
			y_velocity -= y_velocity
		if Input.is_action_just_released("ui_left"):
			x_velocity -= x_velocity
		if Input.is_action_just_released('ui_left'):
			x_velocity -= x_velocity

# Called when the node enters the scene tree for the first time.
func _ready():
	if self.use_script:
		self.use_script_node = use_script.new()
		self.use_script_node.init(self)
	var fly_suit = load_item('flySuit')
	assign_gear(fly_suit)
	
	self.connect("body_entered", self, "_on_body_entered")

func jump():
	var max_z = 20
	if has_gear('flySuit'):
		max_z = 90

	if not has_gear("flySuit") and z > 0:
		return 
		
			
	if has_gear('flySuit') and get_gear('flySuit').is_suspended:
		return
	if z <= 0 or has_gear('flySuit'):
		if z < max_z:
			if has_gear('flySuit'):
				get_gear('flySuit').get_node('Sprite').playing = true
			_z_velocity = 6
		else:
			_z_velocity = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
