extends Node
class_name Economy

var data: Dictionary = {}

const DEFAULT_PRESS := {
    "growth": {"currency": "mana", "cost": 10, "duration": 180.0, "multiplier": 1.25, "fruit": "-", "label": "Growth Brew", "summary": ""},
    "harvest": {"currency": "essence", "cost": 6, "duration": 150.0, "multiplier": 1.4, "fruit": "-", "label": "Harvest Brew", "summary": ""},
    "drop": {"currency": "mana", "cost": 8, "duration": 120.0, "multiplier": 1.3, "fruit": "-", "label": "Drop Brew", "summary": ""}
}

func load_data(values: Dictionary) -> void:
    data = values.duplicate(true)

func get_fruit_spawn_interval() -> float:
    return float(data.get("fruit_spawn_interval", 12.0))

func get_care_duration() -> float:
    return float(data.get("care", {}).get("boost_duration", 20.0))

func get_care_cost(kind: String) -> int:
    var mapping := {
        "water": "water_cost",
        "fertilize": "fertilizer_cost",
        "cure": "cure_cost"
    }
    var key := mapping.get(kind, "")
    if key == "":
        return 0
    return int(data.get("care", {}).get(key, 0))

func get_slot_cost(index: int) -> int:
    var costs: Array = data.get("slot_costs", [])
    if index < costs.size():
        return int(costs[index])
    return 2000 + int(index) * 800

func get_base_coin_rate() -> float:
    return float(data.get("base_coin_rate", 5.0))

func get_offline_multiplier() -> float:
    return float(data.get("offline", {}).get("coin_multiplier", 0.6))

func get_offline_mana_ratio() -> float:
    return float(data.get("offline", {}).get("mana_ratio", 0.2))

func get_offline_essence_ratio() -> float:
    return float(data.get("offline", {}).get("essence_ratio", 0.05))

func get_clock_guard_seconds() -> int:
    return int(data.get("offline", {}).get("clock_guard_seconds", 1800))

func get_press_recipe(kind: String) -> Dictionary:
    var press: Dictionary = data.get("press", {})
    if press.has(kind):
        return {
            "currency": str(press[kind].get("currency", "mana")),
            "cost": int(press[kind].get("cost", 0)),
            "duration": float(press[kind].get("duration", 0.0)),
            "multiplier": float(press[kind].get("multiplier", 1.0)),
            "fruit": str(press[kind].get("fruit", "-")),
            "label": str(press[kind].get("label", kind.capitalize())),
            "summary": str(press[kind].get("summary", ""))
        }
    return DEFAULT_PRESS.get(kind, DEFAULT_PRESS["growth"]).duplicate(true)

func get_breeding_config() -> Dictionary:
    return data.get("breeding", {}).duplicate(true)

func get_prestige_conversion_rate() -> float:
    return float(data.get("prestige", {}).get("conversion_rate", 0.0005))

func get_prestige_bonus(kind: String) -> float:
    return float(data.get("prestige", {}).get("%s_bonus" % kind, 0.0))
