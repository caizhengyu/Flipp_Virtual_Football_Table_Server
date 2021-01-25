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

	
func _player_disconnected(id):
	print("Player " + str(id) + " disconnected!!")
	Players.playerNames.erase(str(id))
	for m in Players.matches:
		if id in m:
			Players.matches.erase(m)



remote func register_names(info):
	print("Player " + str(info.id) + " registered with name " + info.name)
	Players.playerNames[str(info.id)] = info.name


remote func findPublicMatch(playerInfo):
	register_names(playerInfo)
	if Players.matches.size() == 0 or Players.matches[-1].size() == 2:
		Players.matches.append([playerInfo.id])
		return
	var curMatch = Players.matches[-1]
	curMatch.append(playerInfo.id)
	rpc_id(curMatch[0], "public_register_player", curMatch)
	rpc_id(curMatch[1], "public_register_player", curMatch)

	

remote func challengePlayer(playerInfo):
	print(playerInfo)
	if not Players.playerNames.has(str(playerInfo.playerId)):
		return
	var id = get_tree().get_rpc_sender_id()
	register_names({"id": id, "name": name})
	var curMatch = [id, playerInfo.playerId]
	Players.matches.append(curMatch)
	print(Players.matches)
	rpc_id(curMatch[0], "private_register_player", curMatch)
	rpc_id(curMatch[1], "private_register_player", curMatch)
