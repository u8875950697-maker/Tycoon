extends Node

@onready var layer_hills: ColorRect = $"../LayerHills"
@onready var layer_trees: ColorRect = $"../LayerTrees"

@onready var btn_play: Button = $"../VBox/Play"
@onready var btn_opts: Button = $"../VBox/Options"
@onready var btn_quit: Button = $"../VBox/Quit"

var quit_dialog: ConfirmationDialog
var options_dialog: AcceptDialog
var chk_high_contrast: CheckBox
var chk_reduce_motion: CheckBox
var chk_effects: CheckBox

const WORLD_SCENE := "res://scenes/WorldScene.tscn"

var t: float = 0.0

func _ready() -> void:
    if btn_play:
        btn_play.pressed.connect(_on_play_pressed)
    if btn_opts:
        btn_opts.pressed.connect(_on_options_pressed)
    if btn_quit:
        btn_quit.pressed.connect(_on_quit_pressed)

    _build_quit_dialog()
    _build_options_dialog()

func _process(delta: float) -> void:
    t += delta
    if layer_hills:
        layer_hills.position.x = sin(t * 0.25) * 8.0
    if layer_trees:
        layer_trees.position.x = cos(t * 0.35) * 10.0

func _build_quit_dialog() -> void:
    quit_dialog = ConfirmationDialog.new()
    quit_dialog.title = "Spiel beenden?"
    quit_dialog.dialog_text = "Möchtest du das Spiel wirklich verlassen?"
    add_child(quit_dialog)
    quit_dialog.confirmed.connect(_do_quit)

func _build_options_dialog() -> void:
    options_dialog = AcceptDialog.new()
    options_dialog.title = "Optionen"
    options_dialog.dialog_text = ""
    options_dialog.min_size = Vector2(380, 220)
    add_child(options_dialog)

    var root := VBoxContainer.new()
    root.anchor_right = 1.0
    root.anchor_bottom = 1.0
    root.offset_left = 16
    root.offset_top = 16
    root.offset_right = -16
    root.offset_bottom = -16
    options_dialog.add_child(root)

    chk_high_contrast = CheckBox.new()
    chk_high_contrast.text = "Hoher Kontrast"
    root.add_child(chk_high_contrast)

    chk_reduce_motion = CheckBox.new()
    chk_reduce_motion.text = "Animationen reduzieren"
    root.add_child(chk_reduce_motion)

    chk_effects = CheckBox.new()
    chk_effects.text = "Effekte / Partikel anzeigen"
    root.add_child(chk_effects)

    GameState.load_settings()
    chk_high_contrast.button_pressed = bool(GameState.get_setting("high_contrast", false))
    chk_reduce_motion.button_pressed = bool(GameState.get_setting("reduce_motion", false))
    chk_effects.button_pressed = bool(GameState.get_setting("effects_enabled", true))

    chk_high_contrast.toggled.connect(_on_high_contrast_toggled)
    chk_reduce_motion.toggled.connect(_on_reduce_motion_toggled)
    chk_effects.toggled.connect(_on_effects_toggled)

func _on_play_pressed() -> void:
    if ResourceLoader.exists(WORLD_SCENE):
        get_tree().change_scene_to_file(WORLD_SCENE)
    else:
        push_error("WorldScene missing: %s" % WORLD_SCENE)

func _on_options_pressed() -> void:
    if options_dialog:
        options_dialog.popup_centered()

func _on_quit_pressed() -> void:
    if quit_dialog:
        quit_dialog.popup_centered()

func _do_quit() -> void:
    if OS.has_feature("web"):
        var d := AcceptDialog.new()
        d.title = "Info"
        d.dialog_text = "Web-Builds können das Fenster nicht schließen."
        add_child(d)
        d.popup_centered()
    else:
        get_tree().quit()

func _on_high_contrast_toggled(on: bool) -> void:
    GameState.set_setting("high_contrast", on)
    UIManager.apply_high_contrast(on)
    GameState.save_settings()

func _on_reduce_motion_toggled(on: bool) -> void:
    GameState.set_setting("reduce_motion", on)
    UIManager.apply_reduce_motion(on)
    GameState.save_settings()

func _on_effects_toggled(on: bool) -> void:
    GameState.set_setting("effects_enabled", on)
    UIManager.apply_effects_enabled(on)
    GameState.save_settings()
