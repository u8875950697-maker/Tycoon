extends Node
class_name WorldController

const TREES_PATH := "res://data/trees.json"
const FRUITS_PATH := "res://data/fruits.json"
const WORLDS_PATH := "res://data/worlds.json"
const ECONOMY_PATH := "res://data/economy.json"
const MONETIZATION_PATH := "res://data/monetization_flags.json"

var trees: Dictionary = {}
var fruits: Dictionary = {}
var worlds: Dictionary = {}
var economy: Dictionary = {}
var monetization: Dictionary = {}
var world_ids: Array[String] = []
var grid_dimensions: Vector2i = Vector2i(4, 4)
var cell_size: Vector2 = Vector2(2.1, 2.1)

func _ready() -> void:
    load_all()

func load_all() -> void:
    trees = _load_json(TREES_PATH)
    fruits = _load_json(FRUITS_PATH)
    worlds = _load_json(WORLDS_PATH)
    economy = _load_json(ECONOMY_PATH)
    monetization = _load_json(MONETIZATION_PATH)
    world_ids.clear()
    for key in worlds.keys():
        world_ids.append(str(key))
    world_ids.sort()
    Economy.load_data(economy)

func reload() -> void:
    load_all()

func get_world_list() -> Dictionary:
    return worlds.duplicate(true)

func get_world_ids() -> Array[String]:
    return world_ids.duplicate()

func get_world_data(world_id: String) -> Dictionary:
    return worlds.get(world_id, {}).duplicate(true)

func get_tree_data(tree_id: String) -> Dictionary:
    return trees.get(tree_id, {}).duplicate(true)

func get_fruit_data(fruit_id: String) -> Dictionary:
    return fruits.get(fruit_id, {}).duplicate(true)

func get_default_tree_for_world(world_id: String) -> String:
    var world := get_world_data(world_id)
    var natives: Array = world.get("native_trees", [])
    if natives.is_empty():
        if trees.size() > 0:
            return trees.keys()[0]
        return ""
    return str(natives[0])

func get_random_tree_for_world(world_id: String, rng: RandomNumberGenerator) -> String:
    var world := get_world_data(world_id)
    var natives: Array = world.get("native_trees", [])
    if natives.is_empty():
        return get_default_tree_for_world(world_id)
    return str(natives[rng.randi_range(0, natives.size() - 1)])

func get_press_recipes() -> Dictionary:
    return economy.get("press", {}).duplicate(true)

func get_care_config() -> Dictionary:
    return economy.get("care", {}).duplicate(true)

func get_slot_cost(index: int) -> int:
    return Economy.get_slot_cost(index)

func get_breeding_config() -> Dictionary:
    return economy.get("breeding", {}).duplicate(true)

func get_prestige_config() -> Dictionary:
    return economy.get("prestige", {}).duplicate(true)

func get_monetization_flags() -> Dictionary:
    return monetization.duplicate(true)

func get_offline_config() -> Dictionary:
    return economy.get("offline", {}).duplicate(true)

func get_world_effects(world_id: String) -> Dictionary:
    var world := get_world_data(world_id)
    return world.get("effects", {}).duplicate(true)

func get_world_buff(world_id: String) -> Dictionary:
    return get_world_data(world_id).get("buff", {}).duplicate(true)

func get_world_hazard(world_id: String) -> Dictionary:
    return get_world_data(world_id).get("hazard", {}).duplicate(true)

func get_session_lengths(world_id: String) -> Array:
    return get_world_data(world_id).get("session_lengths", [10]).duplicate(true)

func get_world_base_slots(world_id: String) -> int:
    return int(get_world_data(world_id).get("base_slots", 3))

func get_world_goal(world_id: String) -> Dictionary:
    return get_world_data(world_id).get("goal", {}).duplicate(true)

func get_world_visuals(world_id: String) -> Dictionary:
    return get_world_data(world_id).get("visuals", {}).duplicate(true)

func get_plot_position(ix: int, iy: int) -> Vector3:
    var center_x := (grid_dimensions.x - 1) * 0.5
    var center_y := (grid_dimensions.y - 1) * 0.5
    var x := (ix - center_x) * cell_size.x
    var z := (iy - center_y) * cell_size.y
    return Vector3(x, 0.0, z)

func _load_json(path: String) -> Dictionary:
    if not ResourceLoader.exists(path):
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if not file:
        return {}
    var text := file.get_as_text()
    var result := JSON.parse_string(text)
    if typeof(result) == TYPE_DICTIONARY:
        return result
    return {}
