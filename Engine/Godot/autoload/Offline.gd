extends Node
class_name Offline

const DEFAULT_MULTIPLIER := 0.6
const DEFAULT_CATCH_UP_BONUS := 0.2
const MAX_CAP_HOURS := 12.0

func get_cap_hours(world_info: Dictionary, has_prestige_bonus: bool) -> float:
    var base := float(world_info.get("offline_cap_hours", 4))
    if has_prestige_bonus:
        base += 2.0
    return clamp(base, 0.0, MAX_CAP_HOURS)

func get_clock_guard_seconds(config_seconds: int) -> int:
    return max(0, config_seconds)

func calculate(params: Dictionary) -> Dictionary:
    var now := int(params.get("now", Time.get_unix_time_from_system()))
    var last_timestamp := int(params.get("last_timestamp", now))
    var cap_hours := float(params.get("cap_hours", 4.0))
    var clock_guard := int(params.get("clock_guard_seconds", 1800))
    var offline_seconds := max(0, now - last_timestamp)
    if now < last_timestamp or offline_seconds > int(cap_hours * 3600.0) + clock_guard:
        return {
            "ready": false,
            "result": {
                "coins": 0,
                "mana": 0,
                "essence": 0,
                "gems": 0,
                "hours": 0.0,
                "summary": "Clock anomaly detected"
            }
        }
    var offline_hours := min(cap_hours, float(offline_seconds) / 3600.0)
    var multiplier := float(params.get("multiplier", DEFAULT_MULTIPLIER))
    if bool(params.get("catch_up_bonus", false)):
        multiplier *= 1.0 + DEFAULT_CATCH_UP_BONUS
    multiplier *= float(params.get("prestige_multiplier", 1.0))
    var base_coin_rate := float(params.get("base_coin_rate", 5.0))
    var coins := int(round(base_coin_rate * offline_hours * multiplier))
    var mana_ratio := float(params.get("mana_ratio", 0.2))
    var essence_ratio := float(params.get("essence_ratio", 0.05))
    var mana := int(round(coins * mana_ratio))
    var essence := int(round(coins * essence_ratio))
    return {
        "ready": coins > 0 or mana > 0 or essence > 0,
        "result": {
            "coins": coins,
            "mana": mana,
            "essence": essence,
            "gems": 0,
            "hours": offline_hours,
            "summary": "Away for %.1f h" % offline_hours
        }
    }
