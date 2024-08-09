class_name Camera
extends Camera3D

var character
var offset = Vector3(0, 3, -5)

func _init(_character):
	character = _character

func _process(_delta):
	global_position = character.to_global(offset)
	look_at(global_position + character.global_basis.z)
