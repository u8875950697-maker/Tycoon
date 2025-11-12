extends AcceptDialog
class_name RunSummaryPopup

signal continue_requested()
signal prestige_requested()

@onready var stats_label: RichTextLabel = $VBox/Stats
@onready var continue_button: Button = $VBox/Buttons/ContinueButton
@onready var prestige_button: Button = $VBox/Buttons/PrestigeButton

func _ready() -> void:
    get_ok_button().visible = false
    continue_button.pressed.connect(func(): _emit_continue())
    prestige_button.pressed.connect(func(): _emit_prestige())

func show_summary(text: String) -> void:
    stats_label.text = text

func _emit_continue() -> void:
    hide()
    emit_signal("continue_requested")

func _emit_prestige() -> void:
    hide()
    emit_signal("prestige_requested")
