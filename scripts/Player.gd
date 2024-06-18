extends CharacterBody3D

#const scene = preload("res://scenes/Player.tscn")
#const box_scene = preload("res://scenes/box.tscn")

var move_speed = 5.0
var rotation_speed = 2.0
var up_speed = 1
var gravity = .5 # ProjectSettings.get_setting("physics/3d/default_gravity")
var rotation_direction = 0

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
	# Apply the rotation
	rotation.y += rotation_direction * rotation_speed * delta
	move_and_slide()

func handle_command(command):
	match command.command:
		"rotate_right":
			rotation_direction-=1
			if rotation_direction < -1:
				rotation_direction = -1
		"rotate_left":
			rotation_direction+=1
			if rotation_direction > 1:
				rotation_direction = 1

func _physics_process(delta):
	handle_rotation(delta)
	#if Input.is_action_just_pressed("ui_left"):
		#SyncManager.send_command_to_server({ "command": "rotate_left"})
	#if Input.is_action_just_released("ui_left"):
		#SyncManager.send_command_to_server({ "command": "rotate_left"})
	#if Input.is_action_pressed("ui_right"):
		#SyncManager.send_command_to_server({ "command": "rotate_right"})
	#if Input.is_action_pressed("ui_up"):
		#SyncManager.send_command_to_server({ "command": "spawn_box"})
	
func _input(event: InputEvent):
	# not event.pressed means released
	if event.is_action_released("ui_left"):
		SyncManager.send_command_to_server({ "command": "rotate_left"})
	if event.is_action_released("ui_right"):
		SyncManager.send_command_to_server({ "command": "rotate_right"})
	if event.is_action_released("ui_up"):
		SyncManager.send_command_to_server({ "command": "spawn_box"})

