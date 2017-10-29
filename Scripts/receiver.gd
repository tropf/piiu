const TICKRATE = 45

static func receive_start(userdata):
	Global.thread_receiver_mutex.lock()
	while (Global.thread_receiver_keep):
		Global.thread_receiver_mutex.unlock()
	
		var other_players = null
		for child in Global.callback.get_children():
			if child.is_local():
				other_players = child.send_pos_to_server()
		
		OS.sleep_msec(25)
				
		if null == other_players:
			other_players = contact_server("/get")
		Global.callback.parse_players(other_players)
		
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
			OS.delay_msec(50)
		Global.thread_sender_mutex.lock()
			
	print("after loop")
	Global.thread_sender_mutex.unlock()
	return 0

static func contact_server(path):
	var err=0
	var http = HTTPClient.new() # Create the Client
	
	var err = http.connect(Global.server,Global.port) # Connect to host/port
	assert(err==OK) # Make sure connection was OK
	
	while( http.get_status()==HTTPClient.STATUS_CONNECTING or http.get_status()==HTTPClient.STATUS_RESOLVING):
		http.poll()
		OS.delay_usec(500)
	assert( http.get_status() == HTTPClient.STATUS_CONNECTED ) # Could not connect
	var headers=[
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*"
	]
	err = http.request(HTTPClient.METHOD_GET,path,headers) # Request a page from the site (this one was chunked..)
	assert( err == OK ) # Make sure all is OK
	while (http.get_status() == HTTPClient.STATUS_REQUESTING):
		http.poll()
		OS.delay_usec(500)
	assert( http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED ) # Make sure request finished well.
	
	if (http.has_response()):
		var rb = RawArray() # Array that will hold the data
		while(http.get_status()==HTTPClient.STATUS_BODY):
			http.poll()
			var chunk = http.read_response_body_chunk() # Get a chunk
			if (chunk.size()==0):
				OS.delay_usec(1000)
			else:
				rb = rb + chunk # Append to read buffer
		var text = rb.get_string_from_ascii()
		return text
	assert(false)
