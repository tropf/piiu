extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const PLAYER_1_CONTROLLS = "player1"
const PLAYER_2_CONTROLLS = "player2"

func _ready():
	var player_prefab = preload("res://Player.tscn")
	
	var player1_pos = get_node("player1_spawn").get_pos()
	var player2_pos = get_node("player2_spawn").get_pos()
	
	var player1 = player_prefab.instance()
	player1.set_pos(player1_pos)
	player1.set_controlls(PLAYER_1_CONTROLLS)

	var player2 = player_prefab.instance()
	player2.set_pos(player2_pos)
	player2.set_controlls(PLAYER_2_CONTROLLS)
	
	add_child(player1)
	add_child(player2)
