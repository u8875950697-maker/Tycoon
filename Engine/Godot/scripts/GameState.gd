extends Node
class_name GameState

const SAVE_PATH := "user://save.json"

var currencies := {
    "coins": 0,
    "mana": 0,
    "essence": 0,
    "gems": 0,
    "seeds": 0,
    "prestige_leaves": 0,
}

var unlocked_slots := {}
var unlocked_trees := {}
var last_session_timestamp := 0
var prestige_bonuses := {
    "growth": 1.0,
    "fruit": 1.0,
    "mana": 1.0,
}

func _ready() -> void:
    if Engine.is_editor_hint():
        return
    load_state()

func reset_defaults() -> void:
    currencies = {
        "coins": 0,
        "mana": 0,
        "essence": 0,
        "gems": 0,
        "seeds": 0,
        "prestige_leaves": 0,
    }
    unlocked_slots = {}
    unlocked_trees = {}
    last_session_timestamp = Time.get_unix_time_from_system()
    prestige_bonuses = {
        "growth": 1.0,
        "fruit": 1.0,
        "mana": 1.0,
    }

func load_state() -> void:
    reset_defaults()
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return
    var text := file.get_as_text()
    if text.is_empty():
        return
    var result := JSON.parse_string(text)
    if typeof(result) != TYPE_DICTIONARY:
        return
    currencies.merge(result.get("currencies", {}), true)
    unlocked_slots = result.get("unlocked_slots", {})
    unlocked_trees = result.get("unlocked_trees", {})
    last_session_timestamp = int(result.get("last_session_timestamp", last_session_timestamp))
    prestige_bonuses.merge(result.get("prestige_bonuses", {}), true)

func save_state() -> void:
    var data := {
        "currencies": currencies,
        "unlocked_slots": unlocked_slots,
        "unlocked_trees": unlocked_trees,
        "last_session_timestamp": Time.get_unix_time_from_system(),
        "prestige_bonuses": prestige_bonuses,
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return
    file.store_string(JSON.stringify(data))

func add_currency(currency: String, amount: int) -> void:
    if not currencies.has(currency):
        return
    currencies[currency] += amount
    currencies[currency] = max(currencies[currency], 0)

func spend_currency(currency: String, amount: int) -> bool:
    if not currencies.has(currency):
        return false
    if currencies[currency] < amount:
        return false
    currencies[currency] -= amount
    return true

func register_slot(world_name: String, index: int) -> void:
    if not unlocked_slots.has(world_name):
        unlocked_slots[world_name] = []
    if index not in unlocked_slots[world_name]:
        unlocked_slots[world_name].append(index)

func register_tree(tree_id: String) -> void:
    if tree_id in unlocked_trees:
        return
    unlocked_trees[tree_id] = true

func set_prestige_bonus(stat: String, multiplier: float) -> void:
    prestige_bonuses[stat] = multiplier
