extends "res://Scripts/base_player.gd"

var left_input
var right_input
var jump_input
var shoot_input

var server_id = null

func die():
	print("lol now im ded")
	queue_free()
	
func get_server_id():
	if null == server_id:
		server_id = contact_server("/new")
		print("from server: " + server_id)

func _ready():
	get_server_id()

func send_pos_to_server():
	#get_server_id()
	var pos = get_pos()
	var v = get_linear_velocity()
	var xstr = str(pos.x)
	var ystr = str(pos.y)
	var vx = str(v.x)
	var vy = str(v.y)
	
	var path = "/set/" + server_id + "/" + xstr + "/" + ystr + "/" + vx + "/" + vy
	contact_server(path)

func set_controlls(controlls):
	left_input =  controlls + "_left"
	right_input = controlls + "_right"
	jump_input = controlls + "_jump"
	shoot_input = controlls + "_shoot"

func _input(event):
	if event.is_action_pressed(jump_input):
		jump()
	if event.is_action_pressed(shoot_input):
		fire()
		
func _fixed_process(delta):
	if Input.is_action_pressed(right_input):
		move_r(delta)
	if Input.is_action_pressed(left_input):
		move_l(delta)
	aim_to(get_viewport().get_mouse_pos())
	send_pos_to_server()
	
func is_local():
	return true
	
func is_remote():
	return false
	
