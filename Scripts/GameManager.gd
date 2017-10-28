extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const PLAYER_1_CONTROLLS = "player1"
const PLAYER_2_CONTROLLS = "player2"
const player_prefab = preload("res://Prefabs/player.tscn")

func _ready():
	pass

func spawn_players():
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


func _on_btn_level1_pressed():
	var lvl1 = preload("res://Scenes/lvl1.tscn").instance()
	add_child(lvl1)
	remove_child(get_node("level_selection"))
	spawn_players()

func _on_btn_level2_pressed():
	Global.winner = "Mulham"
	get_tree().change_scene("res://Scenes/win_scene.tscn")


func _on_btn_quit_pressed():
	get_tree().quit()
