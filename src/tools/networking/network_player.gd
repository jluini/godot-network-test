extends Reference

class_name NetworkPlayer

var _id
var _player_data
var _is_local
var _is_server

func _init(id, player_data, is_local, is_server):
	_id = id
	_player_data = player_data
	_is_local = is_local
	_is_server = is_server

func get_id():
	return _id

func get_player_name():
	return _player_data

func get_player_data():
	return _player_data

func is_local():
	return _is_local

func is_server():
	return _is_server
