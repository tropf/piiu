extends RigidBody2D
	
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const MAX_SPEED = 400
const ACCELRATION = 1600
const MAX_HITPOINTS = 10

var hitpoints = MAX_HITPOINTS
var current_type = 0

var jumps = 2
var jumping = 0
const BULLET = preload("res://Prefabs/bullet.tscn")
var fire_ready = 0

var stopped = false
var since_stopped = 1
var x_to_be_modified = 0

var barrel = null
var gun = null
var sprite = null

const CHAR_FALLING = preload("res://Assets/players/char_falling.png")
const CHAR_NORMAL = preload("res://Assets/players/char_normal.png")
const CHAR_WALKING_RIGHT = preload("res://Assets/players/char_walking_right.png")
const CHAR_WALKING_LEFT = preload("res://Assets/players/char_walking_left.png")

var player_name = "nameless blob"

#interface:
func move_r(delta):
	if not stopped:
		move_horizontal(delta, 1)

func move_l(delta):
	if not stopped:
		move_horizontal(delta, -1)

func jump():
	if jumps:
		jumps -= 1
		set_linear_velocity(Vector2(0, -700))

func switch_f():
	current_type = (current_type+1)%3
	gun.set_type(current_type)

func switch_b():
	current_type = (current_type-1)%3
	if current_type < 0:
		current_type += 3
	gun.set_type(current_type)

func aim_to(vector2):
	gun.aim_to(vector2)

func fire():
	if fire_ready <=0:
		#apply_impulse(Vector2(0,0),Vector2(-200 * cos(gun.get_rot()), -200 * -sin(gun.get_rot())))
		fire_ready = 0.25
		var bullet = BULLET.instance()
		bullet.set_type(get_current_type())
		bullet.set_rot(gun.get_rot())
		var pos = get_pos() + Vector2(60 * cos(gun.get_rot()), 60 * -sin(gun.get_rot()))
		bullet.set_pos(pos)
		bullet.set_speed(Vector2(500 * cos(gun.get_rot()), 500 * -sin(gun.get_rot())))
		bullet.add_immune(self)
		get_parent().get_parent().add_child(bullet)
		transmit_bullet(bullet)
#END interface

func transmit_bullet(bullet):
	pass

func contact_server(path):
	return Global.send_to_server(path)

func get_max_hitpoints():
	return MAX_HITPOINTS

func get_current_hitpoints():
	return hitpoints
	
func set_hitpoints(points):
	if points > MAX_HITPOINTS:
		hitpoints = MAX_HITPOINTS
	elif points < 0:
		hitpoints = 0
	else:
		hitpoints = points

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	gun = get_node("gun")
	barrel = get_node("gun/barrel")
	sprite = get_node("Sprite")
	# Called every time the node is added to the scene.
	# Initialization here
	#set_use_custom_integrator(true)

func get_player_name():
	return player_name

func set_player_name(name_to_set):
	player_name = name_to_set
	
func get_current_type():
	return current_type
	
func set_current_type(type_to_set):
	current_type = type_to_set
	gun.set_type(type_to_set)
	
func reset_jumps():
	jumps = 2

func set_jumping(x):
	jumping += x
	
func move_horizontal(delta, scale):
	var v = get_linear_velocity()
	if v.x == 0 or scale == 0 or abs(v.x) / v.x == abs(scale) / scale:
		x_to_be_modified += ACCELRATION * delta * scale
	else:
		x_to_be_modified = v.x * -1
		stopped = true
		since_stopped = 0

func _integrate_forces(state):
	var v = state.get_linear_velocity()
	var next_x = v.x
	var initial_x = next_x
	next_x += x_to_be_modified
	x_to_be_modified = 0
	
	if next_x > MAX_SPEED:
		next_x = MAX_SPEED
	elif next_x < -MAX_SPEED:
		next_x = -MAX_SPEED
	
	state.set_linear_velocity(Vector2(next_x, v.y))
	
func die():
	get_tree().change_scene_to(load("res://Scenes/demo_scene.tscn").instance())
	queue_free()
		
func _take_dmg(amount):
	if amount >= hitpoints:
		die()
	else:
		hitpoints -= amount

func is_local():
	return false
	
func is_remote():
	return false

func _notification(what):
	if 1337 == what:
		if 0 == current_type:
			_take_dmg(2)
		elif 1 == current_type:
			_take_dmg(1)
		elif 2 == current_type:
			_take_dmg(4)
	if 1338 == what:
		if 0 == current_type:
			_take_dmg(4)
		elif 1 == current_type:
			_take_dmg(2)
		elif 2 == current_type:
			_take_dmg(1)
	if 1339 == what:
		if 0 == current_type:
			_take_dmg(1)
		elif 1 == current_type:
			_take_dmg(4)
		elif 2 == current_type:
			_take_dmg(2)

func _fixed_process(delta):
	if get_pos().y > get_viewport().get_rect().end.y * 3:
		die()
		
	if since_stopped < 0.03:
		since_stopped += delta
	else:
		stopped = false
	if fire_ready > 0:
		fire_ready -= delta
	if jumping==0:
		sprite.set_texture(CHAR_FALLING)
	else:
		if x_to_be_modified<-10:
			sprite.set_texture(CHAR_WALKING_LEFT)
		elif x_to_be_modified>10:
			sprite.set_texture(CHAR_WALKING_RIGHT)
		else:
			sprite.set_texture(CHAR_NORMAL)
