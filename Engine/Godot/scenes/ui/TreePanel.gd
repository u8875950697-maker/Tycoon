extends Panel
class_name TreePanel

signal care_requested(care_type: String)
signal remove_requested()

@onready var title_label: Label = $VBox/Title
@onready var ability_label: Label = $VBox/Ability
@onready var stats_label: RichTextLabel = $VBox/Stats
@onready var water_button: Button = $VBox/CareContainer/WaterRow/WaterButton
@onready var fertilize_button: Button = $VBox/CareContainer/FertilizeRow/FertilizeButton
@onready var cure_button: Button = $VBox/CareContainer/CureRow/CureButton
@onready var remove_button: Button = $VBox/RemoveButton
@onready var water_bar: ProgressBar = $VBox/CareContainer/WaterRow/WaterBar
@onready var water_timer_label: Label = $VBox/CareContainer/WaterRow/WaterTimer
@onready var fertilize_bar: ProgressBar = $VBox/CareContainer/FertilizeRow/FertilizeBar
@onready var fertilize_timer_label: Label = $VBox/CareContainer/FertilizeRow/FertilizeTimer
@onready var cure_bar: ProgressBar = $VBox/CareContainer/CureRow/CureBar
@onready var cure_status_label: Label = $VBox/CareContainer/CureRow/CureStatus

var current_tree: TreeActor = null

func _ready() -> void:
    water_button.pressed.connect(func(): emit_signal("care_requested", "water"))
    fertilize_button.pressed.connect(func(): emit_signal("care_requested", "fertilize"))
    cure_button.pressed.connect(func(): emit_signal("care_requested", "cure"))
    remove_button.pressed.connect(func(): emit_signal("remove_requested"))
    water_button.tooltip_text = "Water: boosts growth for a short burst"
    fertilize_button.tooltip_text = "Fertilize: increases fruit quality"
    cure_button.tooltip_text = "Cure: clears disease instantly"

func set_tree(tree: TreeActor, info: Dictionary) -> void:
    current_tree = tree
    if tree == null:
        title_label.text = "Tree"
        ability_label.text = "Select a tree"
        stats_label.text = "Select a tree to view stats"
        _set_buttons_disabled(true)
        update_timers({})
        return
    title_label.text = info.get("name", tree.tree_id)
    var ability := info.get("ability", "-")
    var ability_detail := info.get("ability_detail", "")
    ability_label.text = "Ability: %s" % ability.capitalize()
    if ability_detail != "":
        ability_label.text += " — %s" % ability_detail
    var rarity := info.get("rarity", "?")
    var growth := info.get("growth_time", 0)
    var water := info.get("water_need", 0.0)
    var fert := info.get("fertilizer_need", 0.0)
    stats_label.text = "[b]Rarity:[/b] %s\n[b]Growth:[/b] %ss\n[b]Water Need:[/b] %.2f\n[b]Fertilizer Need:[/b] %.2f" % [
        rarity.capitalize(),
        growth,
        water,
        fert,
    ]
    _set_buttons_disabled(false)

func _set_buttons_disabled(state: bool) -> void:
    water_button.disabled = state
    fertilize_button.disabled = state
    cure_button.disabled = state
    remove_button.disabled = state

func update_timers(status: Dictionary) -> void:
    if status.is_empty():
        water_bar.value = 0.0
        fertilize_bar.value = 0.0
        cure_bar.value = 0.0
        water_timer_label.text = "0s"
        fertilize_timer_label.text = "0s"
        cure_status_label.text = "Healthy"
        return
    water_bar.value = clamp(status.get("water", 0.0), 0.0, 1.0)
    fertilize_bar.value = clamp(status.get("fertilizer", 0.0), 0.0, 1.0)
    cure_bar.value = clamp(status.get("disease", 0.0), 0.0, 1.0)
    water_timer_label.text = "%ds" % int(round(status.get("water_time", 0.0)))
    fertilize_timer_label.text = "%ds" % int(round(status.get("fertilizer_time", 0.0)))
    var diseased := bool(status.get("is_diseased", false))
    cure_status_label.text = diseased ? "Needs cure" : "Healthy"
