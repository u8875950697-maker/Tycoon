extends Node
class_name GameState

const SAVE_PATH := "user://save.json"

var tree_definitions := {}
var fruit_definitions := {}
var world_definitions := {}
var economy := {}
var monetization := {}

var currencies := {
    "coins": 0,
    "mana": 0,
    "essence": 0,
    "gems": 0,
    "seeds": 0,
    "prestige_leaves": 0
}

var unlocked_slots := {}
var unlocked_trees := {}
var world_slots := {}
var prestige_upgrades := {}

var last_session_timestamp := 0
var last_session_duration := 0
var current_world_id := "meadow"
var current_session_length := 600
var session_elapsed := 0.0
var session_running := false

var offline_result := {
    "coins": 0,
    "mana": 0,
    "essence": 0,
    "gems": 0,
    "hours": 0.0,
    "summary": ""
}
var offline_ready := false

var breeding_attempts_used := 0
var breeding_reset_time := 0
var breeding_cooldown_end := 0

var ad_views_today := 0
var ad_reset_timestamp := 0

var rng := RandomNumberGenerator.new()

func _ready() -> void:
    if Engine.is_editor_hint():
        return
    rng.randomize()
    initialize()

func initialize() -> void:
    load_definitions()
    load_state()
    compute_offline_rewards()

func load_definitions() -> void:
    tree_definitions = _load_json("res://data/trees.json")
    fruit_definitions = _load_json("res://data/fruits.json")
    world_definitions = _load_json("res://data/worlds.json")
    economy = _load_json("res://data/economy.json")
    Economy.load_data(economy)
    monetization = _load_json("res://data/monetization_flags.json")

func _load_json(path: String) -> Dictionary:
    if not ResourceLoader.exists(path):
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}
    var text := file.get_as_text()
    var result := JSON.parse_string(text)
    if typeof(result) == TYPE_DICTIONARY:
        return result
    return {}

func reset_defaults() -> void:
    currencies = {
        "coins": 150,
        "mana": 0,
        "essence": 0,
        "gems": 0,
        "seeds": 0,
        "prestige_leaves": 0
    }
    unlocked_slots = {}
    world_slots = {}
    unlocked_trees = {}
    prestige_upgrades = {}
    last_session_timestamp = Time.get_unix_time_from_system()
    last_session_duration = 0
    current_world_id = "meadow"
    current_session_length = 600
    breeding_attempts_used = 0
    breeding_reset_time = last_session_timestamp
    breeding_cooldown_end = last_session_timestamp
    ad_views_today = 0
    ad_reset_timestamp = last_session_timestamp

func load_state() -> void:
    reset_defaults()
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return
    var text := file.get_as_text()
    var data := JSON.parse_string(text)
    if typeof(data) != TYPE_DICTIONARY:
        return
    currencies.merge(data.get("currencies", {}), true)
    unlocked_slots = data.get("unlocked_slots", {})
    world_slots = data.get("world_slots", {})
    unlocked_trees = data.get("unlocked_trees", {})
    prestige_upgrades = data.get("prestige_upgrades", {})
    last_session_timestamp = int(data.get("last_session_timestamp", last_session_timestamp))
    last_session_duration = int(data.get("last_session_duration", 0))
    current_world_id = str(data.get("current_world_id", current_world_id))
    current_session_length = int(data.get("current_session_length", current_session_length))
    breeding_attempts_used = int(data.get("breeding_attempts_used", 0))
    breeding_reset_time = int(data.get("breeding_reset_time", last_session_timestamp))
    breeding_cooldown_end = int(data.get("breeding_cooldown_end", last_session_timestamp))
    ad_views_today = int(data.get("ad_views_today", 0))
    ad_reset_timestamp = int(data.get("ad_reset_timestamp", last_session_timestamp))

func save_state() -> void:
    var data := {
        "currencies": currencies,
        "unlocked_slots": unlocked_slots,
        "world_slots": world_slots,
        "unlocked_trees": unlocked_trees,
        "prestige_upgrades": prestige_upgrades,
        "last_session_timestamp": Time.get_unix_time_from_system(),
        "last_session_duration": int(session_elapsed),
        "current_world_id": current_world_id,
        "current_session_length": current_session_length,
        "breeding_attempts_used": breeding_attempts_used,
        "breeding_reset_time": breeding_reset_time,
        "breeding_cooldown_end": breeding_cooldown_end,
        "ad_views_today": ad_views_today,
        "ad_reset_timestamp": ad_reset_timestamp
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data))

func get_tree_data(id: String) -> Dictionary:
    return tree_definitions.get(id, {})

func get_world_data(id: String) -> Dictionary:
    return world_definitions.get(id, {})

func get_fruit_data(id: String) -> Dictionary:
    return fruit_definitions.get(id, {})

func add_currency(type: String, amount: int) -> void:
    if not currencies.has(type):
        return
    currencies[type] = max(0, currencies[type] + amount)

func spend_currency(type: String, amount: int) -> bool:
    if not currencies.has(type):
        return false
    if currencies[type] < amount:
        return false
    currencies[type] -= amount
    return true

func get_unlocked_slots(world_id: String) -> Array:
    return unlocked_slots.get(world_id, [])

func unlock_slot(world_id: String, index: int) -> void:
    if not unlocked_slots.has(world_id):
        unlocked_slots[world_id] = []
    if index not in unlocked_slots[world_id]:
        unlocked_slots[world_id].append(index)

func is_slot_unlocked(world_id: String, index: int) -> bool:
    return index in unlocked_slots.get(world_id, [])

func set_tree_in_slot(world_id: String, index: int, tree_id: String) -> void:
    if not world_slots.has(world_id):
        world_slots[world_id] = {}
    world_slots[world_id][str(index)] = tree_id
    unlocked_trees[tree_id] = true

func remove_tree_from_slot(world_id: String, index: int) -> void:
    if world_slots.has(world_id):
        world_slots[world_id].erase(str(index))

func get_slot_tree(world_id: String, index: int) -> String:
    if not world_slots.has(world_id):
        return ""
    return str(world_slots[world_id].get(str(index), ""))

func record_harvest(fruit_id: String) -> Dictionary:
    var fruit := get_fruit_data(fruit_id)
    if fruit.is_empty():
        return {}
    add_currency("coins", int(fruit.get("coins", 0)))
    add_currency("mana", int(fruit.get("mana", 0)))
    add_currency("essence", int(fruit.get("essence", 0)))
    add_currency("gems", int(fruit.get("gems", 0)))
    if rng.randf() < 0.1:
        add_currency("seeds", 1)
    return fruit

func start_session(world_id: String, duration_seconds: int) -> void:
    current_world_id = world_id
    current_session_length = duration_seconds
    session_elapsed = 0.0
    session_running = true

func update_session(delta: float) -> void:
    if not session_running:
        return
    session_elapsed += delta
    if session_elapsed >= current_session_length:
        session_running = false
        save_state()

func should_end_session() -> bool:
    return not session_running

func compute_offline_rewards() -> void:
    var now := Time.get_unix_time_from_system()
    var world_info := get_world_data(current_world_id)
    var cap_hours := Offline.get_cap_hours(world_info, prestige_upgrades.get("offline", false))
    var offline_data := Offline.calculate({
        "now": now,
        "last_timestamp": last_session_timestamp,
        "cap_hours": cap_hours,
        "clock_guard_seconds": Offline.get_clock_guard_seconds(Economy.get_clock_guard_seconds()),
        "multiplier": Economy.get_offline_multiplier(),
        "catch_up_bonus": last_session_duration > 0 and last_session_duration < 600,
        "base_coin_rate": Economy.get_base_coin_rate(),
        "mana_ratio": Economy.get_offline_mana_ratio(),
        "essence_ratio": Economy.get_offline_essence_ratio(),
        "prestige_multiplier": _get_offline_prestige_multiplier()
    })
    offline_ready = bool(offline_data.get("ready", false))
    offline_result = offline_data.get("result", {
        "coins": 0,
        "mana": 0,
        "essence": 0,
        "gems": 0,
        "hours": 0.0,
        "summary": ""
    })

func has_offline_rewards() -> bool:
    return offline_ready

func collect_offline(mode: String) -> void:
    if not offline_ready:
        return
    var coins := offline_result.get("coins", 0)
    if mode == "ad" and monetization.get("offline_double_ads", true) and _can_use_ad():
        coins *= 2
        ad_views_today += 1
    elif mode == "gems" and monetization.get("offline_double_gems", true) and currencies.get("gems", 0) >= 1:
        if spend_currency("gems", 1):
            coins *= 2
    elif mode == "skip":
        pass
    add_currency("coins", coins)
    add_currency("mana", offline_result.get("mana", 0))
    add_currency("essence", offline_result.get("essence", 0))
    offline_ready = false
    offline_result = {
        "coins": 0,
        "mana": 0,
        "essence": 0,
        "gems": 0,
        "hours": 0,
        "summary": ""
    }

func _can_use_ad() -> bool:
    var now := Time.get_unix_time_from_system()
    if now - ad_reset_timestamp > 86400:
        ad_views_today = 0
        ad_reset_timestamp = now
    var cooldown := int(monetization.get("ad_cooldown_minutes", 10)) * 60
    if now - breeding_cooldown_end < cooldown:
        return false
    if ad_views_today >= int(monetization.get("daily_ad_cap", 3)):
        return false
    return monetization.get("rewarded_ads", true)

func can_use_ad() -> bool:
    return _can_use_ad()

func consume_ad_view() -> void:
    ad_views_today += 1
    breeding_cooldown_end = Time.get_unix_time_from_system()

func _get_offline_prestige_multiplier() -> float:
    var multiplier := 1.0
    if prestige_upgrades.get("growth", false):
        multiplier += Economy.get_prestige_bonus("growth")
    if prestige_upgrades.get("fruit", false):
        multiplier += Economy.get_prestige_bonus("fruit")
    if prestige_upgrades.get("mana", false):
        multiplier += Economy.get_prestige_bonus("mana")
    return multiplier

func get_breeding_data() -> Dictionary:
    var info := Economy.get_breeding_config()
    var free_attempts := max(0, int(info.get("free_attempts", 3)) - breeding_attempts_used)
    var cooldown_remaining := max(0, breeding_cooldown_end - Time.get_unix_time_from_system())
    var cooldown_text := ""
    if cooldown_remaining > 0:
        cooldown_text = "(cooldown %ds)" % cooldown_remaining
    return {
        "attempts": free_attempts,
        "cooldown": cooldown_remaining,
        "cooldown_text": cooldown_text,
        "cooldown_seconds": int(info.get("cooldown_seconds", 120)),
        "gem_fee": int(info.get("gem_fee", 2)),
        "coins": int(info.get("coins", 0)),
        "essence": int(info.get("essence", 0))
    }

func perform_breeding(parent_a: String, parent_b: String, world_id: String) -> Dictionary:
    var info := get_breeding_data()
    if info.get("cooldown", 0) > 0:
        return {"error": "Cooldown active"}
    var free_attempts := info.get("attempts", 0)
    var cost_coins := info.get("coins", 0)
    var cost_essence := info.get("essence", 0)
    if free_attempts <= 0:
        var gem_fee := info.get("gem_fee", 2)
        if currencies.get("gems", 0) < gem_fee:
            return {"error": "Requires %d gems" % gem_fee}
        spend_currency("gems", gem_fee)
        breeding_cooldown_end = Time.get_unix_time_from_system() + int(info.get("cooldown_seconds", 120))
    else:
        breeding_attempts_used += 1
    if cost_coins > 0 and not spend_currency("coins", cost_coins):
        return {"error": "Not enough coins"}
    if cost_essence > 0 and not spend_currency("essence", cost_essence):
        return {"error": "Not enough essence"}
    var base_rarity := _rarity_value(get_tree_data(parent_a).get("rarity", "basic"))
    base_rarity += _rarity_value(get_tree_data(parent_b).get("rarity", "basic"))
    base_rarity = int(round(base_rarity / 2.0))
    var mutation := 0
    var world_info := get_world_data(world_id)
    var mutation_chance := 0.1
    if world_info.get("native_trees", []).has(parent_a) and world_info.get("native_trees", []).has(parent_b):
        mutation_chance += 0.05
    if rng.randf() < mutation_chance:
        mutation = 1
    var rarity_tier := clamp(base_rarity + mutation, 0, 4)
    var seed_id := "%s_%s_seed" % [parent_a, parent_b]
    add_currency("seeds", 1)
    return {
        "seed_id": seed_id,
        "rarity_tier": rarity_tier,
        "mutation": mutation > 0
    }

func _rarity_value(name: String) -> int:
    match name:
        "basic":
            return 0
        "uncommon":
            return 1
        "rare":
            return 2
        "epic":
            return 3
        "legendary":
            return 4
        "mythic":
            return 5
        _:
            return 0

func reset_breeding_if_needed() -> void:
    var now := Time.get_unix_time_from_system()
    if now - breeding_reset_time > 86400:
        breeding_attempts_used = 0
        breeding_reset_time = now

func apply_prestige(total_value: int) -> int:
    var rate := Economy.get_prestige_conversion_rate()
    var earned := int(floor(total_value * rate))
    if earned <= 0:
        return 0
    currencies["prestige_leaves"] += earned
    currencies["coins"] = 200
    currencies["mana"] = 0
    currencies["essence"] = 0
    currencies["gems"] = 0
    unlocked_slots = {}
    world_slots = {}
    unlocked_trees = {}
    session_elapsed = 0
    save_state()
    return earned

func purchase_prestige_upgrade(upgrade_id: String) -> bool:
    var upgrade_costs := {
        "growth": 5,
        "fruit": 5,
        "mana": 5,
        "slots": 8,
        "offline": 6,
        "crit": 7
    }
    if prestige_upgrades.get(upgrade_id, false):
        return false
    var cost := int(upgrade_costs.get(upgrade_id, 5))
    if currencies.get("prestige_leaves", 0) < cost:
        return false
    currencies["prestige_leaves"] -= cost
    prestige_upgrades[upgrade_id] = true
    return true
