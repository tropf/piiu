extends "res://Scripts/base_player.gd"

var left_input
var right_input
var jump_input
var shoot_input
var switch_f_input
var switch_b_input

var since_last_update = 0

var server_id = null

func die():
	contact_server("/die/" + server_id)
	print("lol now im ded")
	queue_free()

func get_server_id():
	return server_id
	
func fetch_server_id():
	if null == server_id:
		server_id = contact_server("/new")
		if Global.id_on_server == null:
			Global.id_on_server = server_id;
		print(server_id)

func _ready():
	fetch_server_id()

func _get_pos_as_server_string():
	var pos = get_pos()
	var v = get_linear_velocity()
	var xstr = str(pos.x)
	var ystr = str(pos.y)
	var vx = str(v.x)
	var vy = str(v.y)
	var orientationstr = str(gun.get_rot())
	var statestr = str(get_current_type())
	var hitponts = str(get_current_hitpoints())
	
	return "/set/" + server_id + "/" + xstr + "/" + ystr + "/" + vx + "/" + vy + "/" + orientationstr + "/" + statestr+ "/"+ hitpoints
	
func send_pos_to_server():
	var path = _get_pos_as_server_string()
	return contact_server(path)

func set_controlls(controlls):
	left_input =  controlls + "_left"
	right_input = controlls + "_right"
	jump_input = controlls + "_jump"
	shoot_input = controlls + "_shoot"
	switch_b_input = controlls + "_switch_b"
	switch_f_input = controlls + "_switch_f"

func _input(event):
	if event.is_action_pressed(jump_input):
		jump()
	if event.is_action_pressed(shoot_input):
		fire()
	if event.is_action_pressed(switch_f_input):
		switch_f()
	if event.is_action_pressed(switch_b_input):
		switch_b()
		
func _fixed_process(delta):
	if Input.is_action_pressed(right_input):
		move_r(delta)
	if Input.is_action_pressed(left_input):
		move_l(delta)
	aim_to(get_viewport().get_mouse_pos())
	
func is_local():
	return true
	
func is_remote():
	return false
	
func transmit_bullet(bullet):
	var pos = bullet.get_pos()
	var xpos = str(pos.x)
	var ypos = str(pos.y)
	var speed = bullet.get_speed()
	var xspeed = str(speed.x)
	var yspeed = str(speed.y)
	var rot = str(bullet.get_rot())
	var type = str(bullet.get_type())
	
	Global.send_to_server("/bullet/"+server_id+"/"+xpos+"/"+ypos+"/"+xspeed+"/"+yspeed+"/"+rot+"/"+type)