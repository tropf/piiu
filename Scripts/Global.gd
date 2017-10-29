extends Node

var winner = ""
var server = "s3nf.net"
var port = 1337
var thread_receiver = null
var thread_receiver_keep = true
var thread_receiver_mutex = Mutex.new()
var thread_sender = null
var thread_sender_keep = true
var thread_sender_mutex = Mutex.new()
var callback = null

var client = null

static func connect_to_server():
	if !client.is_connected():
		
		client = StreamPeerTCP.new()
		client.connect("185.82.23.126",1337)

static func disconnect_from_server():
	
	client.disconnect()




static func send_to_server(data):
	if client.is_connected():
		client.put_utf8_string(data+"\n")
		
		if client.get_available_bytes() >0:
		
			var buf = ""
			var char = ""
			while char != "\n":
				buf += char
				char = client.get_string(1)
				
			return str(buf)
