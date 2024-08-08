extends Node3D

@onready var host_button = $CanvasLayer/Menu/Host
@onready var join_button = $CanvasLayer/Menu/Join

var multiplayer_peer = ENetMultiplayerPeer.new()

const port = 9999
const adress = "127.0.0.1"
var character_prefab = preload("res://character.tscn")

var characters = {} #peer_id: character

func _ready():	
	host_button.connect("pressed", func():
		multiplayer_peer.create_server(port)
		multiplayer.multiplayer_peer = multiplayer_peer
		add_character(1))
	
	join_button.connect("pressed", func():
		multiplayer_peer.create_client(adress, port)
		multiplayer.multiplayer_peer = multiplayer_peer)

	multiplayer.peer_connected.connect(func(peer_id):
		if multiplayer.get_unique_id() == 1:
			remote_add_character.rpc(peer_id)
			remote_add_connected_characters.rpc_id(peer_id, characters.keys())
			add_character(peer_id)
		)
	
	multiplayer.peer_disconnected.connect(func(peer_id):
		if peer_id == 1:
			for p_id in characters.keys():
				delete_character(p_id)
		else:
			delete_character(peer_id)
		)

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

@rpc
func remote_add_character(peer_id):
	add_character(peer_id)

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
