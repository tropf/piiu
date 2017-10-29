const TICKRATE = 45

static func receive_start(userdata):
	Global.thread_receiver_mutex.lock()
	while (Global.thread_receiver_keep):
		Global.thread_receiver_mutex.unlock()
		var other_players = null
		for child in Global.callback.get_children():
			if child.is_local():
				other_players = child.send_pos_to_server()
		
		if null == other_players:
			other_players = contact_server("/get")
		Global.callback.parse_players(other_players)
		OS.delay_msec(15)
		
		Global.thread_receiver_mutex.lock()
	Global.thread_receiver_mutex.unlock()
	return 0
	
static func send_start(userdata):
	var time_per_tick = 1.0 / TICKRATE
	print("sender tickrate: " + str(time_per_tick))
	
	Global.thread_sender_mutex.lock()
	print("les go loop")
	while (Global.thread_sender_keep):
		Global.thread_sender_mutex.unlock()
	
		if true:
			for child in Global.callback.get_children():
				if child.is_local():
					child.call_deferred("send_pos_to_server")
			OS.delay_msec(35)
		Global.thread_sender_mutex.lock()
			
	Global.thread_sender_mutex.unlock()
	return 0


static func contact_server(path):
	return Global.send_to_server(path)