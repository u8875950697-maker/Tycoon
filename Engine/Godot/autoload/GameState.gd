extends Node
class_name GameState

# Currencies
var coins: int = 0
var mana: int = 0
var essence: int = 0
var gems: int = 0
var seeds: int = 0

signal currencies_changed()

const SAVE_PATH := "user://save.json"

func _ready() -> void:
    load_save()

func add_coins(a: int) -> void:
    coins = max(0, coins + a)
    emit_signal("currencies_changed")

func add_mana(a: int) -> void:
    mana = max(0, mana + a)
    emit_signal("currencies_changed")

func add_essence(a: int) -> void:
    essence = max(0, essence + a)
    emit_signal("currencies_changed")

func add_gems(a: int) -> void:
    gems = max(0, gems + a)
    emit_signal("currencies_changed")

func add_seeds(a: int) -> void:
    seeds = max(0, seeds + a)
    emit_signal("currencies_changed")

func save_game() -> void:
    var data := {
        "coins": coins, "mana": mana, "essence": essence,
        "gems": gems, "seeds": seeds
    }
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify(data))
        f.flush()

func load_save() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if not f:
        return
    var txt := f.get_as_text()
    var res := JSON.parse_string(txt)
    if typeof(res) == TYPE_DICTIONARY:
        coins = int(res.get("coins", 0))
        mana = int(res.get("mana", 0))
        essence = int(res.get("essence", 0))
        gems = int(res.get("gems", 0))
        seeds = int(res.get("seeds", 0))
        emit_signal("currencies_changed")
