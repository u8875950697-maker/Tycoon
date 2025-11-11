extends Node3D
class_name WorldScene

@onready var cam: Camera3D = $World/Camera if has_node("World/Camera") else null
@onready var sun: DirectionalLight3D = $World/Sun if has_node("World/Sun") else null

func _ready() -> void:
    # Ensure there is at least something visible if the scene is empty.
    if cam:
        cam.current = true
