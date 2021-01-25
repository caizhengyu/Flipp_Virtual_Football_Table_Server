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
	print(Players.playerNames)
	Players.playerNames.erase(str(id))
	print(Players.playerNames)
	for m in Players.matches:
		print(Players.matches)
		if id in m:
			var oppenentId = m[0]
			if id == m[0]:
				oppenentId = m[1]
			rpc_id(oppenentId, "enemyForfeit")
			Players.matches.erase(m)
			print(oppenentId)


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
	curMatch = _grabNames(curMatch)
	rpc_id(curMatch[0][0], "startMatch", curMatch)
	rpc_id(curMatch[1][0], "startMatch", curMatch)

	

remote func challengePlayer(playerInfo):
	print(playerInfo)
	if not Players.playerNames.has(str(playerInfo.playerId)):
		return
	var id = get_tree().get_rpc_sender_id()
	register_names({"id": id, "name": playerInfo.name})
	var curMatch = [id, playerInfo.playerId]
	Players.matches.append(curMatch)
	curMatch = _grabNames(curMatch)
	rpc_id(curMatch[0][0], "startMatch", curMatch)
	rpc_id(curMatch[1][0], "startMatch", curMatch)


func _grabNames(curMatch):
	var newMatch = [null, null]
	newMatch[0] = [curMatch[0], Players.playerNames[str(curMatch[0])]]
	newMatch[1] = [curMatch[1], Players.playerNames[str(curMatch[1])]]
	return newMatch
