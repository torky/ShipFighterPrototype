extends Node

var players = []
var current_tick = 0
var input_buffer = [] # Store inputs from players for each tick
var input_history = {} # Keep history of inputs for the last N ticks (e.g., 10)
var disconnect_timeout = 5 # Timeout in ticks before considering player disconnected
var max_history_size = 10 # Number of recent ticks to keep
@export var local_address = "127.0.0.1"
@export var server_address = "207.246.95.203"
@export var port = 8910

# Called when the server starts
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	var server = ENetMultiplayerPeer.new()
	# This creates a server with a default max of 32 clients
	var error = server.create_server(port)
	if error != OK:
		print("can't host " + error)
		return
	server.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(server)
	print("Server started, waiting for players...")

func peer_connected(id):
	print("Server: Player Connected " + str(id))
	
func peer_disconnected(id):
	print("Server: Player Disconnected " + str(id))

# Process network events and collect inputs from clients
func _process(delta):
	if get_tree().is_network_server():
		for player in players:
			if not player.is_connected:
				handle_disconnect(player)

		# Wait for inputs from all clients
		if get_tree().network_peer.get_available_packet_count() > 0:
			var packet = get_tree().network_peer.get_packet()
			var player_id = packet.get_string() # Get player ID
			var input_data = packet.get_data() # Get the input data (command)
			handle_input(player_id, input_data)

# Handle received input from a specific player
func handle_input(player_id, input_data):
	input_buffer.append({"player_id": player_id, "input": input_data})
	input_history[current_tick] = input_buffer # Save input for this tick
	print("Received input for tick ", current_tick, " from player ", player_id)

	# Keep only the most recent N ticks in history
	if input_history.size() > max_history_size:
		input_history.erase(input_history.keys()[0])

# Update game state based on inputs and synchronize with clients
func update_game_state():
	# Process the collected inputs for the tick and update game state
	for input_data in input_buffer:
		execute_game_logic(input_data) # Apply the input logic (move units, etc.)

	# Broadcast the inputs (commands) to all clients to ensure synchronization
	for player in players:
		rpc_id(player.id, "_receive_inputs", input_history) # Send the input history to client

	print("Tick ", current_tick, ": Game state updated and inputs broadcasted.")
	current_tick += 1
	input_buffer.clear() # Clear input buffer after processing

# Execute logic based on the input (e.g., move a unit)
func execute_game_logic(input_data):
	var player_id = input_data["player_id"]
	var input = input_data["input"]
	if input["action"] == "move":
		move_unit(input["unit_id"], input["destination"])

# Example of unit movement logic
func move_unit(unit_id, destination):
	if not game_state.has(unit_id):
		game_state[unit_id] = {"position": Vector2(0, 0)} # Initialize unit
	game_state[unit_id]["position"] = destination
	print("Moved unit ", unit_id, " to ", destination)

# Handle disconnected players
func handle_disconnect(player):
	print("Player ", player.id, " disconnected, waiting for reconnection...")
	# Implement reconnection logic, e.g., rolling back game state or pausing
