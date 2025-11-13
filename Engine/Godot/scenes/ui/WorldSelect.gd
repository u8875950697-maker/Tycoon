extends CanvasLayer
class_name WorldSelect

signal world_chosen(world_id: String, session_length: int)

@onready var world_list: VBoxContainer = $Panel/VBox/WorldList
@onready var start_button: Button = $Panel/VBox/StartButton
@onready var session_option: OptionButton = $Panel/VBox/SessionRow/SessionLengths

var selected_world := ""
var selected_length := 10
var world_lengths := {}

func _ready() -> void:
    start_button.disabled = true
    start_button.pressed.connect(_on_start_pressed)
    session_option.item_selected.connect(_on_length_selected)

func populate_worlds(worlds: Dictionary) -> void:
    world_lengths = {}
    for child in world_list.get_children():
        child.queue_free()
    for world_id in worlds.keys():
        var data := worlds[world_id]
        var button := Button.new()
        button.text = "%s — %s" % [str(data.get("display_name", world_id.capitalize())), str(data.get("buff", ""))]
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.pressed.connect(func(id := world_id): _select_world(id, worlds[id]))
        world_list.add_child(button)

func _select_world(world_id: String, data: Dictionary) -> void:
    selected_world = world_id
    var lengths: Array = data.get("session_lengths", [10])
    world_lengths[world_id] = lengths
    session_option.clear()
    for length in lengths:
        session_option.add_item("%d min" % int(length))
    if lengths.size() > 0:
        session_option.select(0)
        selected_length = int(lengths[0]) * 60
    start_button.disabled = false

func _on_length_selected(index: int) -> void:
    if selected_world == "" or not world_lengths.has(selected_world):
        return
    var lengths: Array = world_lengths[selected_world]
    if index >= 0 and index < lengths.size():
        selected_length = int(lengths[index]) * 60

func _on_start_pressed() -> void:
    emit_signal("world_chosen", selected_world, selected_length)
