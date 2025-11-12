extends Node
class_name GameState

var coins: int = 0
var mana: int = 0
var essence: int = 0
var gems: int = 0
var seeds: int = 0

signal currencies_changed()

const SAVE_PATH := "user://save.json"

func _ready() -> void:
    load_save()

func add_coins(amount: int) -> void:
    coins = max(0, coins + amount)
    currencies_changed.emit()

func add_mana(amount: int) -> void:
    mana = max(0, mana + amount)
    currencies_changed.emit()

func add_essence(amount: int) -> void:
    essence = max(0, essence + amount)
    currencies_changed.emit()

func add_gems(amount: int) -> void:
    gems = max(0, gems + amount)
    currencies_changed.emit()

func add_seeds(amount: int) -> void:
    seeds = max(0, seeds + amount)
    currencies_changed.emit()

func save_game() -> void:
    var data := {
        "coins": coins,
        "mana": mana,
        "essence": essence,
        "gems": gems,
        "seeds": seeds
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data))
        file.flush()

func load_save() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return
    var text := file.get_as_text()
    var parsed := JSON.parse_string(text)
    if typeof(parsed) == TYPE_DICTIONARY:
        coins = int(parsed.get("coins", 0))
        mana = int(parsed.get("mana", 0))
        essence = int(parsed.get("essence", 0))
        gems = int(parsed.get("gems", 0))
        seeds = int(parsed.get("seeds", 0))
        currencies_changed.emit()
