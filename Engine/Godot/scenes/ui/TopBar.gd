extends Control
class_name TopBar

signal world_buff_requested

const ICONS := {
    "coins": preload("res://assets/icons/coin.svg"),
    "mana": preload("res://assets/icons/mana.svg"),
    "essence": preload("res://assets/icons/essence.svg"),
    "gems": preload("res://assets/icons/gem.svg"),
    "seeds": preload("res://assets/icons/seed.svg"),
    "timer": preload("res://assets/icons/timer.svg"),
    "buff": preload("res://assets/icons/buff.svg"),
    "hazard": preload("res://assets/icons/hazard.svg")
}

@onready var coins_label: Label = %CoinsLabel
@onready var mana_label: Label = %ManaLabel
@onready var essence_label: Label = %EssenceLabel
@onready var gems_label: Label = %GemsLabel
@onready var seeds_label: Label = %SeedsLabel
@onready var world_label: Label = %WorldLabel
@onready var timer_label: Label = %TimerLabel
@onready var hazard_icon: TextureRect = %HazardIcon
@onready var hazard_label: Label = %HazardLabel
@onready var buff_button: Button = %BuffButton
@onready var buff_status_label: Label = %BuffStatus
@onready var active_buff_container: HBoxContainer = $Panel/HBox/ActiveBuff
@onready var buff_icon: TextureRect = %BuffIcon
@onready var buff_label: Label = %BuffLabel
@onready var coins_icon: TextureRect = %CoinsIcon
@onready var mana_icon: TextureRect = %ManaIcon
@onready var essence_icon: TextureRect = %EssenceIcon
@onready var gems_icon: TextureRect = %GemsIcon
@onready var seeds_icon: TextureRect = %SeedsIcon
@onready var timer_icon: TextureRect = %TimerIcon

var current_world_buff := {}

func _ready() -> void:
    coins_icon.texture = ICONS["coins"]
    mana_icon.texture = ICONS["mana"]
    essence_icon.texture = ICONS["essence"]
    gems_icon.texture = ICONS["gems"]
    seeds_icon.texture = ICONS["seeds"]
    timer_icon.texture = ICONS["timer"]
    buff_icon.texture = ICONS["buff"]
    hazard_icon.texture = ICONS["hazard"]
    buff_button.pressed.connect(_on_buff_pressed)
    buff_button.disabled = true
    buff_status_label.text = "Once per run"

func set_currencies(values: Dictionary) -> void:
    coins_label.text = _format_number(values.get("coins", 0))
    mana_label.text = _format_number(values.get("mana", 0))
    essence_label.text = _format_number(values.get("essence", 0))
    gems_label.text = _format_number(values.get("gems", 0))
    seeds_label.text = _format_number(values.get("seeds", 0))

func set_world_info(name: String, hazard: Dictionary) -> void:
    world_label.text = "World: %s" % name
    hazard_label.text = hazard.get("name", "")
    hazard_icon.modulate = Color(hazard.get("color", "#ffffff"))
    hazard_icon.modulate.a = 0.9 if hazard_label.text != "" else 0.0
    hazard_icon.tooltip_text = hazard.get("description", "")

func set_world_buff(info: Dictionary, available: bool, status_text: String) -> void:
    current_world_buff = info.duplicate()
    var label := info.get("name", "World Buff")
    buff_button.text = label
    buff_button.disabled = not available
    buff_status_label.text = status_text
    var icon_path := info.get("icon", "")
    if icon_path != "" and ResourceLoader.exists(icon_path):
        buff_button.icon = load(icon_path)
    else:
        buff_button.icon = ICONS["buff"]

func set_timer(seconds: float) -> void:
    var total := int(max(0, seconds))
    var minutes := total / 60
    var secs := total % 60
    timer_label.text = "%d:%02d" % [minutes, secs]

func set_buff_badge(data: Dictionary) -> void:
    if data.is_empty():
        active_buff_container.visible = false
        return
    var label := data.get("label", "Buff")
    var mult := float(data.get("mult", 1.0))
    var time_left := int(round(data.get("time", 0.0)))
    var source := data.get("source", "")
    buff_label.text = "%s x%.2f (%ds)%s" % [label, mult, time_left, " — %s" % source if source != "" else ""]
    active_buff_container.visible = true

func set_world_name(name: String) -> void:
    world_label.text = "World: %s" % name

func _format_number(value) -> String:
    if typeof(value) == TYPE_INT:
        return String.num_int64(value)
    if typeof(value) == TYPE_FLOAT:
        return String.num(value, 2)
    return str(value)

func _on_buff_pressed() -> void:
    emit_signal("world_buff_requested")

func set_hazard_summary(text: String) -> void:
    hazard_label.text = text

func set_buff_button_tooltip(text: String) -> void:
    buff_button.tooltip_text = text
