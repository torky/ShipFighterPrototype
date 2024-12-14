extends Node

var last_processed_deltas = 0
var commands = []

# currently only designed for one global call instead of many calls
# we could enable it for a more global system, but I'm not sure that's what I want.
func get_commands_for_timestamp(deltas):
	if last_processed_deltas > deltas:
		print("get_commands - Last processed: " + str(last_processed_deltas) + ", command: " + str(deltas))
		
	var new_commands = []
	var diff_deltas = deltas - 10
	for i in range(commands.size() - 1, -1, -1):
		var current_timestamp = commands[i].timestamp
		if current_timestamp < diff_deltas && commands[i].visited != true:
			new_commands.push_front(commands[i])
			commands[i].visited = true
		elif current_timestamp < last_processed_deltas:
			break
			#print("command retrieved: " + str(server_time) + "," + str(timestamp) + "," + str(diff_client) + "," + str(current_timestamp))
	last_processed_deltas = diff_deltas
	return new_commands

# this will need to be updated to handle redundant commands
@rpc("any_peer", "call_local", "unreliable")
func add_commands(last_10_commands):
	#print(last_10_commands)
	for command in last_10_commands:
		add_command(command)

func add_command(command):
	var index = commands.size()
	for i in range(commands.size() - 1, -1, -1):
		if commands[i].timestamp > command.timestamp or commands[i].index > command.index:
			if (commands[i].index < command.index):
				print("Command out of sync: " + str(commands[i].index) + "," + str(command.index))
			index = i
		elif commands[i].index == command.index:
			# this is when we've already added the command
			return
		else:
			break
	if last_processed_deltas > command.timestamp:
		# This means we have a command that arrived too late
		print("add_command - Last processed: " + str(last_processed_deltas) + ", command: " + str(command.timestamp))
	commands.insert(index, command)
	#print("command inserted " + str(multiplayer.get_unique_id()))
	#print(command)

var server_commands = []
var sequence_number = 0
# This is server code, for now all it does is send back the command to the clients.
@rpc("any_peer", "call_local", "unreliable")
func send_command(command):
	if multiplayer.is_server():
		command.timestamp = GameManager.Game.deltas
		command.visited = false
		command.index = sequence_number
		sequence_number += 1
		server_commands.push_front(command)
		print("server received command " + str(command.timestamp))
		var last_10_commands = []
		var last10 = mini(10, server_commands.size())
		for i in last10:
			last_10_commands.push_front(server_commands[i])
		add_commands.rpc(last_10_commands)
	else:
		print("command not sent to server")

func send_command_to_server(command):
	SyncManager.send_command.rpc_id(1, command)
