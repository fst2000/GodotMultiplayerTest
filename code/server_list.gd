class_name ServerList

var listener : ServerListener
var container : Container

var choosen_server
var servers = {} #server: button

func _init(_listener, _container):
	listener = _listener
	container = _container
	container.create_tween().set_loops().tween_callback(update_list).set_delay(0.1)

func update_list():
	var new_servers = listener.get_servers()
	for new_server in new_servers:
		if !servers.has(new_server):
			add_server_button(new_server)
	for server in servers:
		if !new_servers.has(server):
			servers.get(server).queue_free()

func get_server():
	return choosen_server

func add_server_button(_server):
	var button = Button.new()
	button.text = _server.get("name")
	button.custom_minimum_size = Vector2(200, 50)
	button.pressed.connect(func(): choosen_server = _server)
	container.add_child(button)
	servers.merge({_server: button})
