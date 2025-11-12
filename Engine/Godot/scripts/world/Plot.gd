extends Node3D
class_name Plot

var is_unlocked: bool = true
var has_tree: bool = false

func place_tree(tree_scene: PackedScene) -> Node3D:
    if not is_unlocked or has_tree or tree_scene == null:
        return null
    var tree := tree_scene.instantiate()
    add_child(tree)
    has_tree = true
    return tree

func remove_tree() -> void:
    if not has_tree:
        return
    for child in get_children():
        remove_child(child)
        child.queue_free()
    has_tree = false
