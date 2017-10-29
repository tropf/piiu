extends Node

var winner = ""
var server = "s3nf.net"
var port = 1337
var thread_receiver = null
var thread_receiver_keep = true
var thread_receiver_mutex = Mutex.new()
var callback = null