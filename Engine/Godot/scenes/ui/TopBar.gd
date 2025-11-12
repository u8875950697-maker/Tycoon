extends Control
class_name TopBar

@onready var coins_label: Label = %CoinsLabel
@onready var mana_label: Label = %ManaLabel
@onready var essence_label: Label = %EssenceLabel
@onready var gems_label: Label = %GemsLabel
@onready var seeds_label: Label = %SeedsLabel
@onready var world_label: Label = %WorldLabel
@onready var timer_label: Label = %TimerLabel

func set_currencies(values: Dictionary) -> void:
    coins_label.text = "Coins: %s" % str(values.get("coins", 0))
    mana_label.text = "Mana: %s" % str(values.get("mana", 0))
    essence_label.text = "Essence: %s" % str(values.get("essence", 0))
    gems_label.text = "Gems: %s" % str(values.get("gems", 0))
    seeds_label.text = "Seeds: %s" % str(values.get("seeds", 0))

func set_world_name(name: String) -> void:
    world_label.text = "World: %s" % name

func set_timer(seconds: float) -> void:
    var total := int(seconds)
    var minutes := total / 60
    var secs := total % 60
    timer_label.text = "Time: %d:%02d" % [minutes, secs]
