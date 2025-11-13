extends Node

@export var coins: int = 0

var settings: Dictionary = {
    "high_contrast": false,
    "reduce_motion": false,
    "effects_enabled": true,
}

func add_coins(amount: int) -> void:
    coins += max(0, amount)

func get_setting(key: String, default_value: Variant = null) -> Variant:
    return settings.has(key) ? settings[key] : default_value

func set_setting(key: String, value: Variant) -> void:
    settings[key] = value

func save_settings() -> void:
    pass

func load_settings() -> void:
    pass
