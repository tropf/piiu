extends RigidBody2D

var gun_pos
var fire_rate = 0.5
var last_shot = 0
var bullet_prefab

func _ready():
	gun_pos = get_node("gun").get_pos()
	bullet_prefab = preload("res://Prefabs/bullet.tscn")
	set_process(true)
	
func _process(delta):
	last_shot+= delta
	if(Input.is_action_pressed("shoot") and last_shot >= fire_rate):
		shoot_new()
	
func shoot_new():
	var bullet = bullet_prefab.instance()
	bullet.set_speed(Vector2(250, 0))
	add_child(bullet)
	
	last_shot = 0
	
func shoot():
	var bullet = KinematicBody2D.new()
	bullet.set_pos(gun_pos)
	bullet.set_script(load("res://Scripts/BulletBody.gd"))
	var bullet_sprite = Sprite.new()
	bullet_sprite.set_texture(load("res://Assets/ball.png"))
	bullet.add_child(bullet_sprite)
	var collision = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.set_radius(5)
	collision.set_shape(circle_shape)
	bullet.add_child(collision)
	add_child(bullet)
	
	last_shot = 0 
