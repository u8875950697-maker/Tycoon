extends Panel
class_name PrestigePanel

signal prestige_requested()
signal upgrade_requested(upgrade_id: String)

@onready var leaves_label: Label = $VBox/Leaves
@onready var bonus_list: VBoxContainer = $VBox/BonusList
@onready var summary_label: Label = $VBox/Summary
@onready var prestige_button: Button = $VBox/PrestigeButton

var upgrades := [
    {"id": "growth", "name": "+10% Growth", "cost": 5},
    {"id": "fruit", "name": "+10% Fruit Value", "cost": 5},
    {"id": "mana", "name": "+10% Mana Gain", "cost": 5},
    {"id": "slots", "name": "+1 Starting Slot", "cost": 8},
    {"id": "offline", "name": "Offline Cap +2h", "cost": 6},
    {"id": "crit", "name": "+5% Crit Harvest", "cost": 7}
]

func _ready() -> void:
    prestige_button.pressed.connect(func(): emit_signal("prestige_requested"))
    _build_upgrade_buttons()

func _build_upgrade_buttons() -> void:
    for child in bonus_list.get_children():
        child.queue_free()
    for i in range(upgrades.size()):
        var upgrade := upgrades[i]
        var name := str(upgrade.get("name", "Upgrade"))
        var cost := int(upgrade.get("cost", 0))
        var upgrade_id := str(upgrade.get("id", ""))
        var button := Button.new()
        button.text = "%s (%d leaves)" % [name, cost]
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.pressed.connect(func(): emit_signal("upgrade_requested", upgrade_id))
        bonus_list.add_child(button)

func update_panel(leaves: int, purchased: Dictionary, bonuses: Dictionary) -> void:
    leaves_label.text = "Leaves: %d" % leaves
    var lines: Array[String] = []
    for i in range(upgrades.size()):
        var upgrade := upgrades[i]
        var name := str(upgrade.get("name", "Upgrade"))
        var id: String = str(upgrade.get("id", ""))
        if i < bonus_list.get_child_count():
            var button := bonus_list.get_child(i)
            if button is Button:
                button.disabled = purchased.get(id, false)
        if purchased.get(id, false):
            lines.append("%s unlocked" % name)
    summary_label.text = "Bonuses:\n" + "\n".join(lines)
