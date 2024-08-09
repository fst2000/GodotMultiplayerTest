class_name ServerListener

var udp : PacketPeerUDP
var available_servers = []
var update_tween

func _init(listen_port, scene_tree : SceneTree):
	update_tween = scene_tree.create_tween()
	update_tween.set_loops().tween_callback(check_for_servers).set_delay(1)
	udp = PacketPeerUDP.new()
	udp.bind(listen_port)

func check_for_servers():
	available_servers = []
	while udp.get_available_packet_count() > 0:
		var ip = udp.get_packet_ip()
		var packet = udp.get_packet()
		var server : Dictionary = JSON.parse_string(packet.get_string_from_utf8())
		server.merge({"adress": ip})
		if ip.length() > 0:
			available_servers.append(server)

func get_servers() -> Array:
	return available_servers

func clean_servers():
	available_servers = []

func close():
	if udp:
		udp.close()
	update_tween.kill()
