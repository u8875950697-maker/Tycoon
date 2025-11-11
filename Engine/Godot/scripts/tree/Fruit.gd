extends Sprite3D
class_name FruitBillboard

signal harvested(fruit_id: String, tree_ref: Node)

var fruit_id := ""
var auto_collect_time := 0.0
var auto_collect_delay := 0.0

func setup(id: String, tex: Texture2D, color: Color, delay: float) -> void:
    fruit_id = id
    texture = tex
    modulate = color
    auto_collect_delay = delay
    auto_collect_time = 0.0
    if has_node("AnimationPlayer"):
        var anim_player: AnimationPlayer = get_node("AnimationPlayer")
        anim_player.clear_caches()

func _process(delta: float) -> void:
    if auto_collect_delay <= 0:
        return
    auto_collect_time += delta
    if auto_collect_time >= auto_collect_delay:
        _harvest()

func _input_event(camera: Camera3D, event: InputEvent, click_position: Vector3, click_normal: Vector3, shape_idx: int) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MouseButton.LEFT:
        _harvest()

func _harvest() -> void:
    if not is_inside_tree():
        return
    var tree_ref := get_parent()
    if tree_ref and tree_ref.get_parent():
        tree_ref = tree_ref.get_parent()
    emit_signal("harvested", fruit_id, tree_ref)
    queue_free()
