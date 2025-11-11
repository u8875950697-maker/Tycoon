extends Node3D
class_name TreeActor

signal selected(tree: TreeActor)
signal harvested(fruit_id: String, tree: TreeActor)
signal care_requested(tree: TreeActor, care_type: String)

@onready var layers_root: Node3D = $Layers
@onready var fruit_root: Node3D = $FruitRoot
@onready var selection_sprite: Sprite3D = $Selection
@onready var click_area: Area3D = $"ClickArea"

const FRUIT_SCENE: PackedScene = preload("res://scenes/Fruit.tscn")

var rng := RandomNumberGenerator.new()
var tree_id := ""
var tree_data := {}
var growth_time := 30.0
var growth_progress := 0.0
var base_spawn_interval := 12.0
var water_timer := 0.0
var fertilizer_timer := 0.0
var disease_timer := 0.0
var is_diseased := false
var ability := ""
var ready := false
var external_growth_multiplier := 1.0
var ability_value := 0.0
var world_growth_multiplier := 1.0
var world_disease_multiplier := 1.0
var world_drop_bonus := 0.0

func _ready() -> void:
    rng.randomize()
    if click_area:
        click_area.input_event.connect(_on_click)
    set_process(false)

func setup(id: String, data: Dictionary, spawn_interval: float, modifiers: Dictionary = {}) -> void:
    tree_id = id
    tree_data = data
    ability = data.get("ability", "")
    ability_value = float(data.get("ability_value", 0.0))
    growth_time = max(5.0, float(data.get("growth_time", 30)))
    world_growth_multiplier = float(modifiers.get("growth_multiplier", 1.0))
    world_disease_multiplier = float(modifiers.get("disease_multiplier", 1.0))
    world_drop_bonus = float(modifiers.get("rare_drop_bonus", 0.0))
    if world_growth_multiplier > 0.0:
        growth_time = max(5.0, growth_time / world_growth_multiplier)
    base_spawn_interval = max(2.0, spawn_interval)
    external_growth_multiplier = 1.0
    _build_layers()
    _configure_area()
    growth_progress = 0.0
    water_timer = 0.0
    fertilizer_timer = 0.0
    disease_timer = 0.0
    is_diseased = false
    ready = true
    set_process(true)

func _configure_area() -> void:
    if not click_area:
        return
    var radius := max(1.0, tree_data.get("layers", []).size() * 0.4 + 0.6)
    var collision := click_area.get_node_or_null("CollisionShape3D")
    if collision and collision.shape is SphereShape3D:
        collision.shape.radius = radius

func _build_layers() -> void:
    for child in layers_root.get_children():
        child.queue_free()
    var layers: Array = tree_data.get("layers", [])
    for layer_dict in layers:
        var sprite := Sprite3D.new()
        sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        var tex_path: String = layer_dict.get("texture", "")
        if tex_path != "" and ResourceLoader.exists(tex_path):
            sprite.texture = load(tex_path)
        var pos: Array = layer_dict.get("position", [0, 0, 0])
        if pos.size() >= 3:
            sprite.position = Vector3(float(pos[0]), float(pos[1]), float(pos[2]))
        var scale_data: Array = layer_dict.get("scale", [1, 1, 1])
        if scale_data.size() >= 3:
            sprite.scale = Vector3(float(scale_data[0]), float(scale_data[1]), float(scale_data[2]))
        var modulate_str := str(layer_dict.get("modulate", "#ffffff"))
        sprite.modulate = Color(modulate_str)
        layers_root.add_child(sprite)

func _process(delta: float) -> void:
    if not ready:
        return
    _update_timers(delta)
    _advance_growth(delta)

func _advance_growth(delta: float) -> void:
    var growth_rate := delta / growth_time
    if water_timer > 0:
        growth_rate *= 1.25
    if fertilizer_timer > 0:
        growth_rate *= 1.35
    if ability == "growth_aura":
        growth_rate *= 1.0 + ability_value
    if is_diseased:
        growth_rate *= 0.45
    growth_rate *= external_growth_multiplier
    growth_progress += growth_rate
    if growth_progress >= 1.0:
        growth_progress = 0.0
        _spawn_fruit()
        _roll_disease()

func _update_timers(delta: float) -> void:
    if water_timer > 0:
        water_timer = max(0.0, water_timer - delta)
    if fertilizer_timer > 0:
        fertilizer_timer = max(0.0, fertilizer_timer - delta)
    if disease_timer > 0:
        disease_timer = max(0.0, disease_timer - delta)
        if disease_timer <= 0:
            is_diseased = false

func _spawn_fruit() -> void:
    var fruits: Array = tree_data.get("fruits", [])
    if fruits.is_empty():
        return
    var total_weight := 0.0
    for entry in fruits:
        total_weight += float(entry.get("weight", 1.0))
    var roll := rng.randf_range(0.0, total_weight)
    var selected_id := ""
    for entry in fruits:
        roll -= float(entry.get("weight", 1.0))
        if roll <= 0:
            selected_id = entry.get("id", "")
            break
    if selected_id == "":
        selected_id = fruits[0].get("id", "")
    var fruit_scene: FruitBillboard = FRUIT_SCENE.instantiate()
    var fruit_color := Color(1, 1, 1)
    var fruit_tex := load("res://assets/trees/fruit_round.svg") as Texture2D
    for layer_dict in tree_data.get("layers", []):
        if layer_dict.get("texture", "").find("fruit") != -1:
            fruit_color = Color(layer_dict.get("modulate", "#ffffff"))
            var layer_path := layer_dict.get("texture", "")
            if ResourceLoader.exists(layer_path):
                fruit_tex = load(layer_path)
            break
    var auto_delay := 0.0
    if ability == "auto_harvest":
        auto_delay = max(0.5, ability_value)
    fruit_scene.setup(selected_id, fruit_tex, fruit_color, auto_delay)
    fruit_scene.position = Vector3(rng.randf_range(-0.2, 0.2), rng.randf_range(1.1, 1.6), rng.randf_range(-0.18, -0.05))
    fruit_scene.harvested.connect(_on_fruit_harvested)
    fruit_root.add_child(fruit_scene)
    if ability == "auto_water":
        water_timer = max(water_timer, ability_value)
    if ability == "mana_gen":
        GameState.add_currency("mana", int(round(max(1.0, ability_value))))
    if ability == "aura":
        GameState.add_currency("mana", max(1, int(round(ability_value * 8.0))))

func _on_fruit_harvested(fruit_id: String, tree_ref: Node) -> void:
    emit_signal("harvested", fruit_id, self)

func _roll_disease() -> void:
    var chance := float(tree_data.get("disease_chance", 0.02)) * world_disease_multiplier
    if ability == "aura":
        chance *= 0.7
    if rng.randf() <= chance:
        is_diseased = true
        disease_timer = 20.0

func apply_care(care_type: String, duration: float) -> void:
    match care_type:
        "water":
            water_timer = duration
        "fertilize":
            fertilizer_timer = duration
        "cure":
            is_diseased = false
            disease_timer = 0.0

func set_external_growth(multiplier: float) -> void:
    external_growth_multiplier = multiplier

func set_selected(value: bool) -> void:
    if not selection_sprite:
        return
    selection_sprite.modulate = Color(1, 1, 1, 0.35) if value else Color(1, 1, 1, 0)

func _on_click(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MouseButton.LEFT:
        emit_signal("selected", self)
