extends Node3D
class_name WorldController

@export var world_id := "meadow"
var world_data := {}
var grid_size := Vector2i(4, 4)

func _ready() -> void:
    if Engine.is_editor_hint():
        return
    load_world_data()

func load_world_data() -> void:
    var path := "res://data/worlds.json"
    if not FileAccess.file_exists(path):
        world_data = {}
        return
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        world_data = {}
        return
    var parsed := JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        world_data = {}
        return
    world_data = parsed.get(world_id, {})

func set_world(new_world: String) -> void:
    world_id = new_world
    load_world_data()

func get_plot_count() -> int:
    return grid_size.x * grid_size.y
