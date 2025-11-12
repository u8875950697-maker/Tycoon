extends Node
class_name GameState

signal currencies_changed(values: Dictionary)
signal settings_changed(key: String, value)
signal world_slots_changed(world_id: String, count: int)

const SAVE_PATH := "user://evergrove_save.json"

var currencies := {
    "coins": 0,
    "mana": 0,
    "essence": 0,
    "gems": 0,
    "seeds": 0,
}

var settings := {
    "mute_music": false,
    "mute_sfx": false,
    "high_contrast": false,
    "reduce_motion": false,
}

var world_slots := {} # world_id -> unlocked slot count
var purchased_upgrades := {}
var prestige_leaves := 0
var meta := {
    "last_play_timestamp": 0,
    "last_session_seconds": 0,
    "offline_double_stamp": 0,
    "offline_double_used": false,
    "dev_cheats": false,
    "last_world_id": "",
}

var session_start_timestamp := 0

func _ready() -> void:
    load_save()
    emit_signal("currencies_changed", currencies.duplicate(true))

func get_currencies() -> Dictionary:
    return currencies.duplicate(true)

func get_currency(id: String) -> int:
    return int(currencies.get(id, 0))

func set_currency(id: String, value: int) -> void:
    currencies[id] = max(0, int(value))
    emit_signal("currencies_changed", currencies.duplicate(true))
    save_game()

func add_currency(id: String, amount: int) -> int:
    if amount == 0:
        return get_currency(id)
    currencies[id] = max(0, get_currency(id) + int(amount))
    emit_signal("currencies_changed", currencies.duplicate(true))
    save_game()
    return currencies[id]

func add_currencies(delta: Dictionary) -> void:
    for key in delta.keys():
        add_currency(str(key), int(delta[key]))

func spend_currency(id: String, amount: int) -> bool:
    var current := get_currency(id)
    if amount <= 0:
        return true
    if current < amount:
        return false
    currencies[id] = current - amount
    emit_signal("currencies_changed", currencies.duplicate(true))
    save_game()
    return true

func add_coins(amount: int) -> int:
    return add_currency("coins", amount)

func add_mana(amount: int) -> int:
    return add_currency("mana", amount)

func add_essence(amount: int) -> int:
    return add_currency("essence", amount)

func add_gems(amount: int) -> int:
    return add_currency("gems", amount)

func add_seeds(amount: int) -> int:
    return add_currency("seeds", amount)

func get_all_settings() -> Dictionary:
    return settings.duplicate(true)

func get_setting(key: String, default_value = null):
    if settings.has(key):
        return settings[key]
    return default_value

func set_setting(key: String, value) -> void:
    settings[key] = value
    emit_signal("settings_changed", key, value)
    save_game()

func ensure_world_slots(world_id: String, count: int) -> void:
    if count <= get_world_slots(world_id):
        return
    world_slots[world_id] = count
    emit_signal("world_slots_changed", world_id, count)
    save_game()

func adjust_world_slots(world_id: String, delta: int) -> void:
    var new_total := max(0, get_world_slots(world_id) + delta)
    world_slots[world_id] = new_total
    emit_signal("world_slots_changed", world_id, new_total)
    save_game()

func get_world_slots(world_id: String, fallback: int = 0) -> int:
    return int(world_slots.get(world_id, fallback))

func record_session_start(world_id: String) -> void:
    meta["last_world_id"] = world_id
    session_start_timestamp = Time.get_unix_time_from_system()

func record_session_end(duration_seconds: float) -> void:
    meta["last_session_seconds"] = int(round(duration_seconds))
    meta["last_play_timestamp"] = Time.get_unix_time_from_system()
    save_game()

func get_last_play_timestamp() -> int:
    return int(meta.get("last_play_timestamp", 0))

func update_last_play_timestamp(value: int) -> void:
    meta["last_play_timestamp"] = max(0, value)
    save_game()

func set_offline_double_used(now: int) -> void:
    meta["offline_double_stamp"] = max(0, now)
    meta["offline_double_used"] = true
    save_game()

func can_use_offline_double(now: int, cooldown_seconds: int = 86400) -> bool:
    if not bool(meta.get("offline_double_used", false)):
        return true
    var last := int(meta.get("offline_double_stamp", 0))
    return now - last >= cooldown_seconds

func reset_offline_double(now: int, cooldown_seconds: int = 86400) -> void:
    if can_use_offline_double(now, cooldown_seconds):
        meta["offline_double_used"] = false
        save_game()

func get_prestige_leaves() -> int:
    return int(prestige_leaves)

func add_prestige_leaves(amount: int) -> void:
    prestige_leaves = max(0, prestige_leaves + int(amount))
    save_game()

func spend_prestige_leaves(amount: int) -> bool:
    if amount <= 0:
        return true
    if prestige_leaves < amount:
        return false
    prestige_leaves -= amount
    save_game()
    return true

func set_upgrade_purchased(upgrade_id: String) -> void:
    purchased_upgrades[upgrade_id] = true
    save_game()

func is_upgrade_purchased(upgrade_id: String) -> bool:
    return bool(purchased_upgrades.get(upgrade_id, false))

func get_purchased_upgrades() -> Dictionary:
    return purchased_upgrades.duplicate(true)

func set_dev_cheats(enabled: bool) -> void:
    meta["dev_cheats"] = enabled
    save_game()

func dev_cheats_enabled() -> bool:
    return bool(meta.get("dev_cheats", false))

func get_last_world_id() -> String:
    return str(meta.get("last_world_id", ""))

func save_game() -> void:
    var payload := {
        "currencies": currencies,
        "settings": settings,
        "world_slots": world_slots,
        "purchased_upgrades": purchased_upgrades,
        "prestige_leaves": prestige_leaves,
        "meta": meta,
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(payload))
        file.flush()

func load_save() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if not file:
        return
    var content := file.get_as_text()
    var parsed := JSON.parse_string(content)
    if typeof(parsed) != TYPE_DICTIONARY:
        return
    currencies = _merge_defaults(currencies, parsed.get("currencies", {}))
    settings = _merge_defaults(settings, parsed.get("settings", {}))
    world_slots = parsed.get("world_slots", {}).duplicate(true)
    purchased_upgrades = parsed.get("purchased_upgrades", {}).duplicate(true)
    prestige_leaves = int(parsed.get("prestige_leaves", 0))
    meta = _merge_defaults(meta, parsed.get("meta", {}))

func _merge_defaults(base: Dictionary, incoming) -> Dictionary:
    var result := base.duplicate(true)
    if typeof(incoming) == TYPE_DICTIONARY:
        for key in incoming.keys():
            result[key] = incoming[key]
    return result
