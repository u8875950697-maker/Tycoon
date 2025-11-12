extends Node3D
class_name WorldScene

@onready var cam: Camera3D = has_node("Camera") ? get_node("Camera") as Camera3D : null

func _ready() -> void:
    if cam:
        cam.current = true
