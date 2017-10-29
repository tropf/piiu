extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var Player1 = null
var uid = null

var Players = []

var lenght = null
var dist = null

var players_node = null

var your_hitpoints = null

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	your_hitpoints = get_node("your_hitpoints")
	lenght = your_hitpoints.get_texture().get_width()*your_hitpoints.get_scale().x
	dist = get_node("player2_hitpoints").get_pos().x
	players_node = get_parent().get_node("players")
	

func _process(delta):
	var old_pos = your_hitpoints.get_pos()
	for child in players_node.get_children():
		if child.get_instance_ID() == uid:
			your_hitpoints.set_pos(Vector2( (Player1.get_current_hitpoints()-Player1.get_max_hitpoints())*lenght/Player1.get_max_hitpoints(), old_pos.y))
		
		if players_node.get_children().size() != Players.size()+1:
			var is_first = true
			Players = []
			for child in players_node.get_children():
				if is_first:
					Player1 = child
					uid = child.get_instance_ID()
					is_first = false
				else:
					Players.append([child, child.get_instance_ID()])
				var scale = get_node("player2_hitpoints").get_scale()
				if Players.size()==1:
					print("hi")
					scale = Vector2(scale.x ,0.18)
					get_node("player3_hitpoints").set_hidden(true)
					get_node("player4_hitpoints").set_hidden(true)
					get_node("player2_hitpoints").set_scale(scale)
				elif Players.size()==2:
					scale = Vector2(scale.x ,0.09)
					get_node("player4_hitpoints").set_hidden(true)
					var pos = get_node("player3_hitpoints").get_pos()
					get_node("player3_hitpoints").set_pos(Vector2(pos.x, pos.y+20))
					get_node("player2_hitpoints").set_scale(scale)
					get_node("player3_hitpoints").set_scale(scale)
				elif Players.size()==0:
					get_node("player2_hitpoints").set_hidden(true)
					get_node("player3_hitpoints").set_hidden(true)
					get_node("player4_hitpoints").set_hidden(true)
		
	var count = 1
	for i in Players:
		count += 1
		var player = i[0] 
		var player_uid = i[1]
		var old_pos = get_node("player"+str(count)+"_hitpoints").get_pos()
		for child in players_node.get_children():
			if child.get_instance_ID() == player_uid:
				get_node("player"+str(count)+"_hitpoints").set_pos((Vector2( dist-(player.get_current_hitpoints()-player.get_max_hitpoints())*(lenght)/player.get_max_hitpoints(), old_pos.y)))