extends RigidBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const MAX_SPEED = 400
const ACCELRATION = 1600

var jumps = 2

var stopped = false
var since_stopped = 1
var x_to_be_modified = 0

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	# Called every time the node is added to the scene.
	# Initialization here
	#set_use_custom_integrator(true)
	
func reset_jumps():
	jumps = 2

func move_horizontal(delta, scale):
	var v = get_linear_velocity()
	if v.x == 0 or scale == 0 or abs(v.x) / v.x == abs(scale) / scale:
		x_to_be_modified += ACCELRATION * delta * scale
	else:
		x_to_be_modified = v.x * -1
		stopped = true
		since_stopped = 0

func _integrate_forces(state):
	var v = state.get_linear_velocity()
	var next_x = v.x
	var initial_x = next_x
	next_x += x_to_be_modified
	x_to_be_modified = 0
	
	if next_x > MAX_SPEED:
		next_x = MAX_SPEED
	elif next_x < -MAX_SPEED:
		next_x = -MAX_SPEED
	
	state.set_linear_velocity(Vector2(next_x, v.y))
	
func _input(event):
	if jumps and Input.is_action_pressed("ui_up"):
		jumps -= 1
		set_linear_velocity(Vector2(0, -900))
	
func _fixed_process(delta):
	if not stopped and Input.is_action_pressed("ui_right"):
		move_horizontal(delta, 1)
	if not stopped and Input.is_action_pressed("ui_left"):
		move_horizontal(delta, -1)
	if since_stopped < 0.03:
		since_stopped += delta
	else:
		stopped = false