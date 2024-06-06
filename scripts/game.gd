extends Node3D

const PLAYER = preload("res://scenes/player.tscn")
const box_scene = preload("res://scenes/box.tscn")
var deltas = 0;
var time_lapsed = 0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.physics_ticks_per_second = 60  # Example value for determinism
	Engine.physics_jitter_fix = 0
	#var index = 0
	#for i in GameManager.Players:
		#if GameManager.Players[i].id == 1:
			#var currentPlayer = PLAYER.instantiate()
			#
			#add_child(currentPlayer)
			#var new_position = spawn.position
			#new_position.y += index
			#currentPlayer.global_position = new_position
			#index+=1
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	deltas+=1
	time_lapsed+=delta;
	if deltas % 10 == 0: 
		var commands = SyncManager.get_commands_for_timestamp(deltas)
		for command in commands:
			if command.command == "spawn_box":
				#print("Time: " + str(deltas) + ", " + str(command.timestamp) + ", " + str(time_lapsed))
				spawn_box()
	
func spawn_box():
	#print("spawn box for " + str(multiplayer.get_unique_id()))
	var box = box_scene.instantiate()
	var spawn = GameManager.Spawn
	var pos = spawn.position
	box.position = pos
	add_child(box)
