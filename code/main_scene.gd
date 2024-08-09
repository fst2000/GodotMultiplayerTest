extends Node3D

@onready var menu = $CanvasLayer/Menu
@onready var host_button = $CanvasLayer/Menu/Host
@onready var server_name = $CanvasLayer/Menu/ServerName
@onready var join_button = $CanvasLayer/Menu/Join
@onready var server_list_container = $CanvasLayer/Menu/ServerListContainer

var character_prefab = preload("res://prefabs/character.tscn")

var multiplayer_peer = ENetMultiplayerPeer.new()

var characters = {} #peer_id: character
var cameras = {} #peer_id, camera

var port = 16173
var broadcast_port = 28519
var listen_port = 28518
var server_broadcaster : ServerBroadcaster
var server_listener : ServerListener
var broadcast_tween
var server_list

func _ready():
	server_listener = ServerListener.new(listen_port, get_tree())
	server_list = ServerList.new(server_listener, server_list_container)
	host_button.connect("pressed", func():
		menu.visible = false
		server_broadcaster = ServerBroadcaster.new(broadcast_port, listen_port, server_name.text)
		broadcast_tween = create_tween().set_loops().tween_callback(server_broadcaster.update_broadcast).set_delay(1)
		multiplayer_peer.create_server(port)
		multiplayer.multiplayer_peer = multiplayer_peer
		add_character(1)
		add_camera(1))
	
	join_button.connect("pressed", func():
		var server = server_list.get_server()
		if server:
			menu.visible = false
			multiplayer_peer.create_client(server.get("adress"), port)
			multiplayer.multiplayer_peer = multiplayer_peer)

	multiplayer.peer_connected.connect(func(peer_id):
		if multiplayer.get_unique_id() == 1:
			remote_add_character_with_camera.rpc(peer_id)
			remote_add_connected_characters.rpc_id(peer_id, characters.keys())
			add_character(peer_id)
		)
	
	multiplayer.peer_disconnected.connect(func(peer_id):
		delete_character(peer_id))
	
	multiplayer.server_disconnected.connect(func():
		broadcast_tween.kill()
		for p_id in characters.keys():
			delete_character(p_id))

func _exit_tree():
	if server_broadcaster:
		server_broadcaster.close()
	server_listener.close()

func add_character(peer_id):
	var character = character_prefab.instantiate()
	characters.merge({peer_id: character}, true)
	character.set_multiplayer_authority(peer_id)
	character.name = "Player " + str(peer_id)
	add_child(character)
	character.global_position.x = randf()

func delete_character(peer_id):
	var character = characters.get(peer_id)
	if is_instance_valid(character): character.queue_free()
	characters.erase(peer_id)

func add_camera(peer_id):
	var camera = Camera.new(characters.get(peer_id))
	cameras.merge({peer_id: camera})
	add_child(camera)

func delete_camera(peer_id):
	var camera = cameras.get(peer_id)
	if is_instance_valid(camera):
		camera.queue_free()
	cameras.erase(peer_id)

@rpc
func remote_add_camera(peer_id):
	add_camera(characters.get(peer_id)) 

@rpc
func remote_add_character(peer_id):
	add_character(peer_id)

@rpc
func remote_add_character_with_camera(peer_id):
	add_character(peer_id)
	add_camera(peer_id)

@rpc
func remote_delete_character(peer_id):
	delete_character(peer_id)

@rpc
func remote_add_connected_characters(peer_ids):
	for peer_id in peer_ids:
		add_character(peer_id)

@rpc
func remote_delete_characters(peer_ids):
	for peer_id in peer_ids:
		delete_character(peer_id)
