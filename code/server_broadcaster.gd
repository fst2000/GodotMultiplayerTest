class_name ServerBroadcaster

var udp : PacketPeerUDP
var name

func _init(broadcast_port, listen_port, _name):
	if _name.length() == 0: name = "Server"
	else: name = _name
	udp = PacketPeerUDP.new()
	udp.set_broadcast_enabled(true)
	udp.set_dest_address("255.255.255.255", listen_port)
	udp.bind(broadcast_port)

func update_broadcast():
	var message = {"name": name}
	message = JSON.stringify(message)
	udp.put_packet(message.to_utf8_buffer())

func close():
	if udp:
		udp.close()
