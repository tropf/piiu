extends Container

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	get_node("Label").set_text("Congrats " + Global.winner + "!\nyou have won")
	if null != Global.thread_receiver:
		Global.thread_receiver.wait_to_finish()
		Global.thread_receiver = null