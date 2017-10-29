extends "res://Scripts/base_player.gd"

func is_local():
	return false
	
func is_remote():
	return true

func set_aim(aim):
	gun.set_rot(aim)

