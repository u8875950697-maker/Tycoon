extends Node3D
class_name PlotTile

signal plot_selected(plot: PlotTile)
signal unlock_requested(plot: PlotTile)

@onready var area: Area3D = $Area
@onready var indicator: Sprite3D = $Indicator
@onready var tree_socket: Node3D = $TreeSocket
@onready var lock_sprite: Sprite3D = $LockSprite
@onready var price_label: Label3D = $PriceLabel
@onready var unlock_particles: GPUParticles3D = $UnlockParticles

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
    var was_unlocked := unlocked
    unlocked = value
    if indicator:
        indicator.modulate = Color(1, 1, 1, 0.1) if value else Color(0.95, 0.7, 0.3, 0.35)
    if lock_sprite:
        lock_sprite.visible = not value
    if price_label:
        price_label.visible = not value and cost > 0
    if value and not was_unlocked:
        _play_unlock_fx()

func attach_tree(tree_scene: TreeActor) -> void:
    if tree_scene == null:
        return
    tree = tree_scene
    var parent_node := tree_socket if tree_socket else self
    parent_node.add_child(tree_scene)
    tree_scene.position = Vector3(0, 0.05, 0)

func remove_tree() -> void:
    if tree:
        tree.queue_free()
        tree = null

func set_price(value: int) -> void:
    cost = max(0, value)
    if price_label:
        price_label.text = cost > 0 ? "Unlock %d" % cost : ""
        price_label.visible = not unlocked and cost > 0

func _play_unlock_fx() -> void:
    if unlock_particles:
        unlock_particles.emitting = false
        unlock_particles.emitting = true

func _on_input(camera: Camera3D, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MouseButton.LEFT:
        if unlocked:
            emit_signal("plot_selected", self)
        else:
            emit_signal("unlock_requested", self)
