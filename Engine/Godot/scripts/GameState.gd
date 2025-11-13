extends Node
class_name GameState

@export var coins: int = 0
var mana: int = 0
var essence: int = 0
var gems: int = 0
var seeds: int = 0

var settings: Dictionary = {
    "high_contrast": false,
    "reduce_motion": false,
    "effects_enabled": true
}

func add_coins(amount: int) -> void:
    coins = max(0, coins + amount)

func add_mana(amount: int) -> void:
    mana = max(0, mana + amount)

func add_essence(amount: int) -> void:
    essence = max(0, essence + amount)

func add_gems(amount: int) -> void:
    gems = max(0, gems + amount)

func add_seeds(amount: int) -> void:
    seeds = max(0, seeds + amount)

func get_setting(key: String, default_value: Variant = null) -> Variant:
    if settings.has(key):
        return settings[key]
    return default_value

func set_setting(key: String, value: Variant) -> void:
    settings[key] = value

func save_settings() -> void:
    pass

func load_settings() -> void:
    pass
