extends Node

signal peer_started # (as_server: bool)
signal connect_as_client_failed # ()

var DEFAULT_IP = "127.0.0.1"
var SERVER_PORT = 32400
var MAX_PLAYERS = 20

enum NetworkState {
	None,
	Server,
	ConnectingAsClient,
	ConnectedClient
}
var _network_state = NetworkState.None

# Initialization

func initialize():
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	# only in clients
	# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_ok")
	# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connected_fail")
	# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
# Network peer creation

func create_peer(player_data, as_server) -> bool:
	var server_or_client = "server" if as_server else "client"
	if _network_state != NetworkState.None:
		Logger.warn("Can't start as %s: already using networking" % server_or_client)
		return false
	
	var peer = NetworkedMultiplayerENet.new()
	
	var result
	if as_server:
		result = peer.create_server(SERVER_PORT, MAX_PLAYERS)
	else:
		result = peer.create_client(DEFAULT_IP, SERVER_PORT)
	
	if result != OK:
		Logger.error(_network_error_message("start %s" % server_or_client, result))
		return false
	
	get_tree().network_peer = peer
	
	_network_state = NetworkState.Server if as_server else NetworkState.ConnectingAsClient
	
	return true

func create_server(player_data) -> bool:
	var ok = create_peer(player_data, true)
	
	if ok:
		_emit_deferred("peer_started", true)
	
	return ok

func create_client(player_data) -> bool:
	var ok = create_peer(player_data, false)
	
	if ok:
		Logger.info("Trying to connect as client...")
	
	return ok

func cancel_attempt() -> bool:
	if _network_state != NetworkState.ConnectingAsClient:
		Logger.warn("Can't cancel attempt, I'm not trying to connect as client (%s)" % _state_str())
		return false
	
	_network_state = NetworkState.None
	get_tree().network_peer = null
	
	return true

# Network signals handling

func _player_connected(id):
	Logger.debug("TODO: _player_connected(%s)" % id)

func _player_disconnected(id):
	Logger.debug("TODO: _player_disconnected(%s)" % id)

func _connected_ok():
	if _network_state != NetworkState.ConnectingAsClient:
		Logger.warn("Wasn't expecting _connected_ok()")
		return
	
	_network_state = NetworkState.ConnectedClient
	
	emit_signal("peer_started", false)

func _connected_fail():
	if _network_state != NetworkState.ConnectingAsClient:
		Logger.warn("Wasn't expecting _connected_ok()")
		return
	
	_network_state = NetworkState.None
	
	emit_signal("connect_as_client_failed")

func _server_disconnected():
	Logger.debug("TODO: _server_disconnected()")

# Signaling

func _emit_deferred(signal_name, param):
	call_deferred("emit_signal", signal_name, param)

# Error utils

func _network_error_message(action, result) -> String:
	return "Could not %s: %s" % [action, _network_error_description(result)]

func _network_error_description(result) -> String:
	match result:
		ERR_ALREADY_IN_USE:
			return "connection already in use"
		ERR_CANT_CREATE:
			return "can't be created"
		_:
			return "unknown error %s" % result

func _state_str(state = null) -> String:
	if state == null:
		state = _network_state
	return NetworkState.keys()[state]
