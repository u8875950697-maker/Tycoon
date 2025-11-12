extends Node3D
class_name WorldScene

@onready var camera: Camera3D = $Camera
@onready var sun: DirectionalLight3D = $Sun

func _ready() -> void:
    if camera:
        camera.current = true
