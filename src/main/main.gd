extends Node

const VIEW_MENU = 0
const VIEW_LOBBY = 1

enum MainState {
	InitialMenu,
	CreatingPeer,
	Lobby
}
var _state = MainState.InitialMenu

onready var network_manager = $network_manager
onready var views = $ui/main_screen/views
onready var name_field = $ui/main_screen/views/menu_view/menu/v_box_container/peer_form/name_field
onready var wait_bar = $ui/main_screen/wait_bar

# Initialization

func _ready():
	Logger.set_output($ui/side_bar/screen_logger, true)
	
	network_manager.connect("peer_started", self, "_on_peer_started")
	network_manager.connect("connect_as_client_failed", self, "_on_connect_as_client_failed")
	
	network_manager.initialize()

# Button handlers

func _on_create_server_pressed():
	if not _check_state(MainState.InitialMenu, "_on_create_server_pressed"):
		return
	
	if network_manager.create_server(_get_peer_name()):
		_wait_peer_creation()
	else:
		Logger.warn("Couldn't create server")

func _on_connect_to_server_pressed():
	if not _check_state(MainState.InitialMenu, "_on_connect_to_server_pressed"):
		return
	
	if network_manager.create_client(_get_peer_name()):
		_wait_peer_creation()
	else:
		Logger.warn("Couldn't create client")

func _on_cancel_button_pressed():
	if not _check_state(MainState.CreatingPeer, "_on_cancel_button_pressed"):
		return
	
	if network_manager.cancel_attempt():
		_stop_waiting()
	else:
		Logger.warn("Couldn't cancel connection attempt")

# Network signal handlers

func _on_peer_started(_as_server):
	if not _check_state(MainState.CreatingPeer, "_on_peer_started"):
		return
	
	_state = MainState.Lobby
	wait_bar.hide()
	views.switch_to_view(VIEW_LOBBY)

func _on_connect_as_client_failed():
	if not _check_state(MainState.CreatingPeer, "_on_connect_as_client_failed"):
		return
	
	_stop_waiting()
	
# States

func _wait_peer_creation():
	_state = MainState.CreatingPeer
	
	$ui/main_screen/views/menu_view/menu/v_box_container/create_server.disabled = true
	$ui/main_screen/views/menu_view/menu/v_box_container/connect_to_server.disabled = true
	wait_bar.show()

func _stop_waiting():
	_state = MainState.InitialMenu
	
	$ui/main_screen/views/menu_view/menu/v_box_container/create_server.disabled = false
	$ui/main_screen/views/menu_view/menu/v_box_container/connect_to_server.disabled = false
	wait_bar.hide()

func _check_state(expected_state, action: String) -> bool:
	var state_is_ok = _state == expected_state
	if not state_is_ok:
		Logger.warn("%s: state should be %s but is %s" % [action, _state_str(expected_state), _state_str(_state)])
	
	return state_is_ok

# Utils & Misc

func _get_peer_name():
	var name = name_field.text
	if not name:
		name = _random_name()

func _random_name():
	return "Peer #%s" % (randi() % 1000 + 1000)

func _state_str(state) -> String:
	return MainState.keys()[state]
