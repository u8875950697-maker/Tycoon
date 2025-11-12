extends Panel
class_name TreePanel

signal care_requested(care_type: String)
signal remove_requested()

@onready var title_label: Label = $VBox/Title
@onready var stats_label: RichTextLabel = $VBox/Stats
@onready var water_button: Button = $VBox/Buttons/WaterButton
@onready var fertilize_button: Button = $VBox/Buttons/FertilizeButton
@onready var cure_button: Button = $VBox/Buttons/CureButton
@onready var remove_button: Button = $VBox/RemoveButton

var current_tree: TreeActor = null

func _ready() -> void:
    water_button.pressed.connect(func(): emit_signal("care_requested", "water"))
    fertilize_button.pressed.connect(func(): emit_signal("care_requested", "fertilize"))
    cure_button.pressed.connect(func(): emit_signal("care_requested", "cure"))
    remove_button.pressed.connect(func(): emit_signal("remove_requested"))

func set_tree(tree: TreeActor, info: Dictionary) -> void:
    current_tree = tree
    if tree == null:
        title_label.text = "Tree"
        stats_label.text = "Select a tree to view stats"
        water_button.disabled = true
        fertilize_button.disabled = true
        cure_button.disabled = true
        remove_button.disabled = true
        return
    title_label.text = info.get("name", tree.tree_id)
    var ability := info.get("ability", "-")
    var rarity := info.get("rarity", "?")
    var growth := info.get("growth_time", 0)
    var water := info.get("water_need", 0.0)
    var fert := info.get("fertilizer_need", 0.0)
    stats_label.text = "[b]Rarity:[/b] %s\n[b]Ability:[/b] %s\n[b]Growth:[/b] %ss\n[b]Water:[/b] %.2f\n[b]Fertilizer:[/b] %.2f" % [rarity.capitalize(), ability, growth, water, fert]
    water_button.disabled = false
    fertilize_button.disabled = false
    cure_button.disabled = false
    remove_button.disabled = false
