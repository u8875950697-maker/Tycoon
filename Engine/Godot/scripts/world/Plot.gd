extends Node3D
class_name Plot

var is_unlocked: bool = true
var has_tree: bool = false

func place_tree(scene: PackedScene) -> Node3D:
    if not is_unlocked or has_tree or scene == null:
        return null
    var t := scene.instantiate()
    add_child(t)
    has_tree = true
    return t
