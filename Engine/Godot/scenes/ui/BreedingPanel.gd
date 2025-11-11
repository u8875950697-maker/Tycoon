extends Panel
class_name BreedingPanel

signal breed_requested(parent_a: String, parent_b: String)

@onready var attempts_label: Label = $VBox/Attempts
@onready var parent_a_option: OptionButton = $VBox/ParentRow/ParentA
@onready var parent_b_option: OptionButton = $VBox/ParentRow/ParentB
@onready var odds_label: Label = $VBox/Odds
@onready var result_label: Label = $VBox/Result
@onready var breed_button: Button = $VBox/BreedButton

var tree_ids: Array[String] = []

func _ready() -> void:
    breed_button.pressed.connect(_on_breed_pressed)

func set_tree_options(ids: Array) -> void:
    tree_ids = ids.duplicate()
    parent_a_option.clear()
    parent_b_option.clear()
    for id in ids:
        parent_a_option.add_item(id.capitalize())
        parent_b_option.add_item(id.capitalize())
    parent_a_option.select(0 if ids.size() > 0 else -1)
    parent_b_option.select(0 if ids.size() > 1 else 0)

func set_attempts_remaining(free_attempts: int, cooldown_text: String) -> void:
    attempts_label.text = "Attempts left: %d %s" % [free_attempts, cooldown_text]
    breed_button.disabled = free_attempts <= 0 and cooldown_text != ""

func set_odds_text(text: String) -> void:
    odds_label.text = text

func set_result(text: String) -> void:
    result_label.text = text

func _on_breed_pressed() -> void:
    if tree_ids.is_empty():
        return
    var parent_a_idx := parent_a_option.get_selected_id()
    var parent_b_idx := parent_b_option.get_selected_id()
    if parent_a_idx < 0 or parent_a_idx >= tree_ids.size():
        parent_a_idx = 0
    if parent_b_idx < 0 or parent_b_idx >= tree_ids.size():
        parent_b_idx = min(1, tree_ids.size() - 1)
    var parent_a := tree_ids[parent_a_idx]
    var parent_b := tree_ids[parent_b_idx]
    emit_signal("breed_requested", parent_a, parent_b)
