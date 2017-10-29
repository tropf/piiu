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
	pass	

func _ready():
	pass
	
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
	
func is_local():
	return true
	
func is_remote():
	return false
	
