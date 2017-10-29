extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const PLAYER_1_CONTROLLS = "player1"
const PLAYER_2_CONTROLLS = "player2"
const player_prefab = preload("res://Prefabs/player.tscn")
const hud = preload("res://Scenes/HUD.tscn")
var current_lvl = null
var player_controls = {}

func _ready():
	player_controls[0] = PLAYER_1_CONTROLLS
	player_controls[1] = PLAYER_2_CONTROLLS

func spawn_players():
	Global.connect_to_server()
	
	var spawns = []
	for single_spawn in current_lvl.get_node("spawns").get_children():
		spawns.append(single_spawn.get_pos())
		
	for i in range(spawns.size()):
		var rand_min = 0
		var rand_max = spawns.size() - i - 1
		var rand_nr = int(rand_range(rand_min, rand_max + 0.999))
		
		var tmp = spawns[rand_nr]
		spawns[rand_nr] = spawns[rand_max]
		spawns[rand_max] = tmp
		
	for i in range(player_controls.size()):
		var player = player_prefab.instance()
		player.set_pos(spawns[i])
		player.set_controlls(player_controls[i])
		get_node("players").add_child(player)
	
	get_node("players").set_process(true)
	
	get_node("level_selection").queue_free()
	
	Global.callback = get_node("players")
	Global.thread_receiver = Thread.new()
	Global.thread_receiver.start(preload("res://Scripts/receiver.gd"), "receive_start")	

	#Global.thread_sender = Thread.new()
	#Global.thread_sender.start(preload("res://Scripts/receiver.gd"), "send_start")

func _on_btn_level1_pressed():
	var lvl1 = preload("res://Scenes/lvl0.tscn").instance()
	current_lvl = lvl1
	add_child(lvl1)
	spawn_players()
	add_child(hud.instance())
	

func _on_btn_level2_pressed():
	var lvl2 = preload("res://Scenes/lvl2.tscn").instance()
	current_lvl = lvl2
	add_child(lvl2)
	spawn_players()
	add_child(hud.instance())

func _on_btn_quit_pressed():
	get_tree().quit()
