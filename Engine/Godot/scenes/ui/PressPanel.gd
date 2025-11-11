extends Panel
class_name PressPanel

signal craft_requested(kind: String)
signal dev_cheats_toggled(enabled: bool)

@onready var growth_button: Button = $VBox/Recipes/GrowthButton
@onready var harvest_button: Button = $VBox/Recipes/HarvestButton
@onready var drop_button: Button = $VBox/Recipes/DropButton
@onready var status_label: Label = $VBox/Status
@onready var dev_toggle: CheckButton = $VBox/DevToggle
@onready var growth_detail: Label = $VBox/Recipes/GrowthDetail
@onready var growth_summary: Label = $VBox/Recipes/GrowthSummary
@onready var harvest_detail: Label = $VBox/Recipes/HarvestDetail
@onready var harvest_summary: Label = $VBox/Recipes/HarvestSummary
@onready var drop_detail: Label = $VBox/Recipes/DropDetail
@onready var drop_summary: Label = $VBox/Recipes/DropSummary

func _ready() -> void:
    growth_button.pressed.connect(func(): emit_signal("craft_requested", "growth"))
    harvest_button.pressed.connect(func(): emit_signal("craft_requested", "harvest"))
    drop_button.pressed.connect(func(): emit_signal("craft_requested", "drop"))
    dev_toggle.toggled.connect(func(pressed: bool): emit_signal("dev_cheats_toggled", pressed))

func set_status(text: String) -> void:
    status_label.text = text

func show_dev_toggle(visible_flag: bool, enabled: bool) -> void:
    dev_toggle.visible = visible_flag
    dev_toggle.button_pressed = enabled

func configure_recipes(recipes: Dictionary) -> void:
    _apply_recipe(recipes.get("growth", {}), growth_button, growth_detail, growth_summary)
    _apply_recipe(recipes.get("harvest", {}), harvest_button, harvest_detail, harvest_summary)
    _apply_recipe(recipes.get("drop", {}), drop_button, drop_detail, drop_summary)

func _apply_recipe(data: Dictionary, button: Button, detail: Label, summary: Label) -> void:
    if data.is_empty():
        button.disabled = true
        detail.text = "Unavailable"
        summary.text = ""
        return
    button.disabled = false
    if data.has("label"):
        button.text = str(data.get("label"))
    var uses := str(data.get("fruit", "-"))
    var cost := "%d %s" % [int(data.get("cost", 0)), str(data.get("currency", "coins"))]
    var duration := "%ds" % int(data.get("duration", 0))
    detail.text = "Uses: %s | Cost: %s | Duration: %s" % [uses, cost, duration]
    summary.text = str(data.get("summary", ""))
