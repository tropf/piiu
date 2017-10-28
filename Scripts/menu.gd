extends Container

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	randomize()

func _on_btn_newGame_pressed():
	get_tree().change_scene("res://Scenes/demo_scene.tscn")

func _on_btn_quit_pressed():
	get_tree().quit()
