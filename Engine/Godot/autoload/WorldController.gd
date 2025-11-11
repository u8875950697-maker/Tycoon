extends Node
class_name WorldController

const GRID_SIZE := Vector2i(4, 4)

var current_world_id := "meadow"
var current_world := {}

func _ready() -> void:
    if Engine.is_editor_hint():
        return
    load_world(current_world_id)

func load_world(world_id: String) -> void:
    current_world_id = world_id
    current_world = GameState.get_world_data(world_id)

func get_grid_size() -> Vector2i:
    return GRID_SIZE

func get_worlds() -> Dictionary:
    return GameState.world_definitions

func get_current_world() -> Dictionary:
    return current_world

func get_world_offline_cap(world_id: String) -> int:
    return int(GameState.get_world_data(world_id).get("offline_cap_hours", 4))

func get_base_slots(world_id: String) -> int:
    return int(GameState.get_world_data(world_id).get("base_slots", 3))

func get_available_tree_ids(world_id: String) -> Array:
    var world_info := GameState.get_world_data(world_id)
    var native := world_info.get("native_trees", [])
    var result: Array = []
    for tree_id in GameState.tree_definitions.keys():
        var tree := GameState.get_tree_data(tree_id)
        if tree.get("biome", "") == "universal" or native.has(tree_id) or world_id == "meadow":
            result.append(tree_id)
    return result

func get_slot_cost(index: int) -> int:
    var costs: Array = GameState.economy.get("slot_costs", [])
    if index < costs.size():
        return int(costs[index])
    return 2000 + (index * 800)

func apply_world_bonuses(tree: TreeActor) -> void:
    if tree == null:
        return
    var ability := GameState.get_tree_data(tree.tree_id).get("ability", "")
    if ability == "aura":
        GameState.add_currency("mana", 1)
