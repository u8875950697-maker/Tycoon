extends Node3D
class_name WorldScene

@onready var cam: Camera3D = $"Camera" if has_node("Camera") else null

func _ready() -> void:
    if cam:
        cam.current = true
