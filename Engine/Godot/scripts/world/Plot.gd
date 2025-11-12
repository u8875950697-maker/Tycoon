extends Node3D
class_name PlotTile

signal plot_selected(plot: PlotTile)
signal unlock_requested(plot: PlotTile)

@onready var area: Area3D = $Area
@onready var indicator: Sprite3D = $Indicator

var index := 0
var unlocked := false
var tree: TreeActor = null
var cost := 0

func _ready() -> void:
    if area:
        area.input_event.connect(_on_input)

func set_visual(color: Color) -> void:
    if indicator:
        indicator.modulate = color

func set_unlocked(value: bool) -> void:
    unlocked = value
    if indicator:
        indicator.modulate = Color(1, 1, 1, 0) if value else Color(0.9, 0.6, 0.2, 0.5)

func attach_tree(tree_scene: TreeActor) -> void:
    if tree_scene == null:
        return
    tree = tree_scene
    add_child(tree_scene)
    tree_scene.position = Vector3(0, 0.05, 0)

func remove_tree() -> void:
    if tree:
        tree.queue_free()
        tree = null

func _on_input(camera: Camera3D, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MouseButton.LEFT:
        if unlocked:
            emit_signal("plot_selected", self)
        else:
            emit_signal("unlock_requested", self)
