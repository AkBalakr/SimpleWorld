extends CharacterBody3D

#@export allows the variable to be modified via the inspector allowing for quick modifications
@export var mouse_sens = 0.001
#These three variables are activly updated and used when the mouse look is activated
var twist_input = 0.0
var pitch_input = 0.0
var zoom_input = 0.0

@export var SPEED = 5.00
@export var JUMP_VELOCITY = 200.00
var GRAVITY = -(ProjectSettings.get_setting("physics/3d/default_gravity"))

#@onready allows for nicknames of nodes for readability
@onready var twist_pivot = $TwistPivot
@onready var pitch_pivot = $TwistPivot/PitchPivot
@onready var player_camera = $TwistPivot/PitchPivot/SpringArm3D
@onready var player_mesh = $MeshInstance3D


#function runs every frame; delta representing the amount of frames skipped due to hardware
#USE THE DELTA TO CALCULATE MOVEMENT in order to keep a consistent feel despite frame skips
func _process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if velocity.y < -500:
			velocity.y = -500
	camera_rotate()
	get_move_input(delta)
	move_and_slide()
	#print("get_platform_angular_velocity", get_platform_angular_velocity())

#Constantly runs within _process and is the main driver for the camera functionality
func camera_rotate():
	#checks if M2 is pressed and released to change mouse mode for camera input
	if Input.is_action_pressed("rightclick"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif Input.is_action_just_released("rightclick"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	#updates the camera's angle using variables updated by the _unhandled_input function
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	#prevents rotation that would intersect with the player
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-70.0), deg_to_rad(30.0))
	#prevents drifting
	twist_input = 0
	pitch_input = 0
var max_jumps = 2; var jumps = 0;
func get_move_input(delta):
	
	if Input.is_action_just_pressed("jump") and jumps < max_jumps:
		velocity.y = JUMP_VELOCITY*delta
		jumps += 1
	elif jumps >= max_jumps and is_on_floor(): 
		print("brother I am grounded")
		jumps = 0
		
	#inorder to allow movement based on camera orientation; we save the y velocicity in order to freely do the x and z calculations
	var vy = velocity.y
	velocity.y = 0
	#creates a Vector2 element that stores the 2d axis of movement from the user's input
	var input = Input.get_vector("moveleft", "moveright", "moveup", "movedown")
	#if input.x + input.y > 0:
		#print("input", input)
	#converts the cardinal directions of the user's input and rotats it around the y axis based on the camera angle in radians
	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, twist_pivot.rotation.y)
	#print("velocty", velocity)
	
	#take velocity.x and velocity.z and calculate angle to determine orientation of the character
	#later find a way to make it a more smooth rotation
	#var face_direction = velocity.normalized()
	var face_direction = velocity.normalized()
	print("velocity ", velocity," norm: ", face_direction)
	#face_direction[1] = 0
	#print("face_direction", face_direction)
	#print("face_direcation", face_direction)
	#rotate(tan(face_direction[0]/face_direction[2]))
	#print("tan: ", face_direction[0]/face_direction[2])
	#look_at(face_direction, Vector3.UP) # not smooth at all (hard to see if its actually working with pure white)
	
	velocity = dir*(SPEED+(delta*SPEED))
	velocity.y = vy

#Handles all events that weren't used up by the GUI; recomended for gameplay input
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sens
			pitch_input = - event.relative.y * mouse_sens
	elif event is InputEventMouseButton:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				player_camera.position.z = player_camera.position.z - .5
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				player_camera.position.z = player_camera.position.z + .5
			player_camera.position.z = clamp(player_camera.position.z, -0.5, 10)
	
