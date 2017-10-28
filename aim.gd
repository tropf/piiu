extends Position2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	
func _process(delta):
	set_rot(to_angle(get_viewport().get_mouse_pos() - get_parent().get_pos() ))
	
func to_angle(vector):
	return (atan2(vector.x, vector.y) - PI/2)