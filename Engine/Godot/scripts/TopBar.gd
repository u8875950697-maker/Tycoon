extends Control
class_name TopBar

@onready var coins_label: Label = %CoinsLabel
@onready var mana_label: Label = %ManaLabel
@onready var essence_label: Label = %EssenceLabel
@onready var gems_label: Label = %GemsLabel
@onready var seeds_label: Label = %SeedsLabel

func set_currencies(values: Dictionary) -> void:
    coins_label.text = "Coins: %s" % str(values.get("coins", 0))
    mana_label.text = "Mana: %s" % str(values.get("mana", 0))
    essence_label.text = "Essence: %s" % str(values.get("essence", 0))
    gems_label.text = "Gems: %s" % str(values.get("gems", 0))
    seeds_label.text = "Seeds: %s" % str(values.get("seeds", 0))
