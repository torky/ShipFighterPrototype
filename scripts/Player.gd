extends CharacterBody3D

#const scene = preload("res://scenes/Player.tscn")
#const box_scene = preload("res://scenes/box.tscn")

var move_speed = 5.0
var rotation_speed = 2.0
var up_speed = 1
var gravity = .5 # ProjectSettings.get_setting("physics/3d/default_gravity")

func handle_input(delta):
	# Handle floating.
	if Input.is_action_pressed("ui_accept") and velocity.y < 2:
		velocity.y += up_speed
	elif velocity.y > -2:
		velocity.y -= gravity
	
	# Capture the input for movement and rotation
	var input_move = 0
	var input_turn = 0

	# note we should create our own like move_forward, move_back, rotate_left, rotate_right and shit
	if Input.is_action_pressed("ui_up"):
		input_move = -1
	if Input.is_action_pressed("ui_down"):
		input_move = 1
	if Input.is_action_pressed("ui_left"):
		input_turn = 1
	if Input.is_action_pressed("ui_right"):
		input_turn = -1

	# Calculate the movement direction
	var direction = (transform.basis * Vector3(0, 0, input_move)).normalized()
	
	# Apply the rotation
	rotation.y += input_turn * rotation_speed * delta
	
	if direction:
		velocity.x = direction.x
		velocity.z = direction.z
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
	
	# Move the player
	move_and_slide()
	
func handle_rotation(delta):
	var input_turn = 0
	if Input.is_action_pressed("ui_left"):
		input_turn = 1
	if Input.is_action_pressed("ui_right"):
		input_turn = -1
	
	# Apply the rotation
	rotation.y += input_turn * rotation_speed * delta
	move_and_slide()

func _physics_process(delta):
	handle_rotation(delta)
	if Input.is_action_pressed("ui_up"):
		SyncManager.send_command.rpc_id(1, { "command": "spawn_box"})
	

