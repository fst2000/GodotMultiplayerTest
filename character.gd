extends CharacterBody3D

@onready var label = $Label3D

var gravity = 10

func _ready():
	label.text = name

func _physics_process(delta):
	if is_multiplayer_authority():
		var move_input = Input.get_vector("right", "left", "down", "up")
		velocity.x = move_input.x * 4
		velocity.z = move_input.y * 4
		if Input.is_action_pressed("jump") && is_on_floor():
			velocity.y = 10
		velocity.y -= gravity * delta
		remote_set_position.rpc(global_position)
	move_and_slide()

@rpc("unreliable")
func remote_set_position(_global_position):
	global_position = _global_position
