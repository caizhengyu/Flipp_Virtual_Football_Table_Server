extends Node2D

var net = NetworkedMultiplayerENet.new()
var port = 6969
var max_players = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	net.create_server(port, max_players)
	get_tree().set_network_peer(net)
	print("hosting")

	
func _player_connected(id):
	print("Player "+ str(id) + " connected!!")
	Players.playerIds.append(id)
	if Players.playerIds.size() == 2:
		rpc_id(Players.playerIds[0], "register_player", Players.playerIds)
		rpc_id(Players.playerIds[1], "register_player", Players.playerIds)
		Players.playerIds = []
	
func _player_disconnected(id):
	print("Player " + str(id) + " disconnected!!")
	if id in Players.playerIds:
		Players.playerIds = []

remote func register_names(info):
	print("Player " + info.id + " registered with name " + info.name)
	Players.playerNames
