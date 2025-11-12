extends Node3D
class_name Plot

signal plot_selected(plot: Plot)
signal unlock_requested(plot: Plot)

@onready var area: Area3D = $Area
@onready var indicator: Sprite3D = $Indicator
@onready var tree_socket: Node3D = $TreeSocket
@onready var lock_sprite: Sprite3D = $LockSprite
@onready var price_label: Label3D = $PriceLabel
@onready var particles: GPUParticles3D = $UnlockParticles

var index := 0
var is_unlocked: bool = true
var has_tree: bool = false
var price: int = 0
var reduce_motion_enabled := false
var current_tree: Node3D = null

func _ready() -> void:
    if area:
        area.input_event.connect(_on_area_input)
    _refresh_visuals()

func configure(idx: int, slot_price: int, unlocked: bool, reduce_motion: bool) -> void:
    index = idx
    price = max(0, slot_price)
    is_unlocked = unlocked
    reduce_motion_enabled = reduce_motion
    if lock_sprite:
        lock_sprite.visible = not is_unlocked
    if price_label:
        price_label.text = price > 0 ? "Unlock %d" % price : "Unlocked"
        price_label.visible = not is_unlocked and price > 0
    if particles:
        particles.emitting = false
        particles.one_shot = true
        particles.visible = not reduce_motion_enabled
    _set_indicator(false)

func place_tree(scene: PackedScene) -> Node3D:
    if not is_unlocked or has_tree or scene == null:
        return null
    var tree := scene.instantiate()
    tree_socket.add_child(tree)
    has_tree = true
    current_tree = tree
    _set_indicator(false)
    return tree

func clear_tree() -> void:
    if current_tree and is_instance_valid(current_tree):
        current_tree.queue_free()
    current_tree = null
    has_tree = false

func set_locked(state: bool) -> void:
    is_unlocked = not state
    if lock_sprite:
        lock_sprite.visible = state
    if price_label:
        price_label.visible = state and price > 0
    if not state:
        _play_unlock_fx()

func set_price_tag(text: String) -> void:
    if price_label:
        price_label.text = text

func highlight(active: bool) -> void:
    _set_indicator(active)

func apply_reduce_motion(enabled: bool) -> void:
    reduce_motion_enabled = enabled
    if particles:
        particles.visible = not enabled

func show_unlock_price(visible_flag: bool) -> void:
    if price_label:
        price_label.visible = visible_flag

func get_tree() -> Node3D:
    return current_tree

func _on_area_input(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MouseButton.LEFT:
        if is_unlocked:
            emit_signal("plot_selected", self)
        else:
            emit_signal("unlock_requested", self)

func _set_indicator(active: bool) -> void:
    if indicator:
        indicator.modulate.a = 0.55 if active else 0.0

func _refresh_visuals() -> void:
    if lock_sprite:
        lock_sprite.visible = not is_unlocked
    if price_label:
        price_label.visible = not is_unlocked and price > 0

func _play_unlock_fx() -> void:
    if particles and not reduce_motion_enabled:
        particles.emitting = true
        particles.restart()
