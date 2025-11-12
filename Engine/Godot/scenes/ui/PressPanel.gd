extends Panel
class_name PressPanel

signal craft_requested(kind: String)
signal dev_cheats_toggled(enabled: bool)

@onready var growth_button: Button = $VBox/Buttons/GrowthButton
@onready var harvest_button: Button = $VBox/Buttons/HarvestButton
@onready var drop_button: Button = $VBox/Buttons/DropButton
@onready var status_label: Label = $VBox/Status
@onready var dev_toggle: CheckButton = $VBox/DevToggle

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
