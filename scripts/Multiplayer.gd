extends Control

@export var host_address = "127.0.0.1"
@export var server_address = "207.246.95.203"
@export var port = 8910
var peer
const GAME = preload("res://scenes/game.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

	if "--server" in OS.get_cmdline_args():
		host_game()

# server and client
func peer_connected(id):
	print("Player Connected " + str(id))
	
# server and client
func peer_disconnected(id):
	print("Player Disconnected " + str(id))
	
# client - send info from client to server
func connected_to_server():
	print("Connected to server")
	send_player_information.rpc_id(1, $LineEdit.text, multiplayer.get_unique_id())
	
# client
func server_disconnected():
	print("Disconnected from server")
	
# client
func connection_failed():
	print("Connection failed")

# https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html#remote-procedure-calls
@rpc("any_peer", "call_remote", "reliable")
func send_player_information(playerName, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"playerName": playerName,
			"id": id,
			"score": 0,
		}
		if multiplayer.is_server():
			for i in GameManager.Players:
				send_player_information.rpc(GameManager.Players[i].playerName, i)

@rpc("any_peer", "call_local")
func start_game():
	print("start game - " + str(multiplayer.get_unique_id()))
	var game = GAME.instantiate()
	GameManager.Game = game;
	GameManager.Spawn = game.get_node("Spawn")
	#print(GameManager.Game)
	#print(GameManager.Spawn)
	#print(GameManager.Spawn.position)
	get_tree().root.add_child(game)
	self.hide()
	
## probably for server level stuff
#@rpc("authority", "call_remote")
#func start_host_game():
	#var ticks = Time.get_ticks_msec()
	#start_game(ticks).rpc()

func host_game():
	# create new multiplayer peer
	peer = ENetMultiplayerPeer.new()
	# This creates a server with a default max of 32 clients
	var error = peer.create_server(port)
	if error != OK:
		print("can't host " + error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
	print("Waiting for Players")

func _on_host_button_down():
	host_game()
	send_player_information($LineEdit.text, multiplayer.get_unique_id())

func _on_join_button_down():
	# create new multiplayer peer
	peer = ENetMultiplayerPeer.new()
	# connect to host
	peer.create_client(server_address, port)
	# get host
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

func _on_start_game_button_down():
	start_game.rpc()
