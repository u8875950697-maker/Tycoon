extends Node

@onready var btn_play: Button = $"../VBox/Play"
@onready var btn_opts: Button = $"../VBox/Options"
@onready var btn_quit: Button = $"../VBox/Quit"

@onready var layer_hills: ColorRect = $"../LayerHills"
@onready var layer_trees: ColorRect = $"../LayerTrees"

const WORLD_SCENE := "res://scenes/WorldScene.tscn"

var _time: float = 0.0
var _reduce_motion_enabled: bool = false
var _effects_enabled: bool = true

var _options_dialog: AcceptDialog
var _quit_dialog: ConfirmationDialog
var _toggle_high_contrast: CheckButton
var _toggle_reduce_motion: CheckButton
var _toggle_effects: CheckButton
var _syncing_options: bool = false

func _ready() -> void:
    GameState.load_settings()
    _reduce_motion_enabled = bool(GameState.get_setting("reduce_motion", false))
    _effects_enabled = bool(GameState.get_setting("effects_enabled", true))
    var high_contrast := bool(GameState.get_setting("high_contrast", false))

    UIManager.apply_high_contrast(high_contrast)
    UIManager.apply_reduce_motion(_reduce_motion_enabled)
    UIManager.apply_effects_enabled(_effects_enabled)

    if btn_play:
        btn_play.pressed.connect(_on_play_pressed)
    if btn_opts:
        btn_opts.pressed.connect(_on_options_pressed)
    if btn_quit:
        btn_quit.pressed.connect(_on_quit_pressed)

func _process(delta: float) -> void:
    if _reduce_motion_enabled:
        if layer_hills:
            layer_hills.position.x = 0.0
        if layer_trees:
            layer_trees.position.x = 0.0
        return

    _time += delta
    if layer_hills:
        layer_hills.position.x = sin(_time * 0.25) * 10.0
    if layer_trees:
        layer_trees.position.x = cos(_time * 0.35) * 14.0

func _on_play_pressed() -> void:
    if ResourceLoader.exists(WORLD_SCENE):
        get_tree().change_scene_to_file(WORLD_SCENE)
    else:
        push_error("WorldScene missing: %s" % WORLD_SCENE)

func _on_options_pressed() -> void:
    _ensure_options_dialog()
    _sync_option_states()
    if _options_dialog:
        _options_dialog.popup_centered()

func _on_quit_pressed() -> void:
    _ensure_quit_dialog()
    if _quit_dialog:
        _quit_dialog.popup_centered()

func _ensure_options_dialog() -> void:
    if _options_dialog:
        return

    _options_dialog = AcceptDialog.new()
    _options_dialog.title = "Optionen"
    _options_dialog.dialog_text = ""
    _options_dialog.ok_button_text = "Schließen"
    _options_dialog.min_size = Vector2(360, 200)

    var content := VBoxContainer.new()
    content.anchor_right = 1.0
    content.offset_right = 320.0
    content.custom_minimum_size = Vector2(320, 0)
    content.theme_override_constants.separation = 12

    _toggle_high_contrast = CheckButton.new()
    _toggle_high_contrast.text = "Hoher Kontrast"
    _toggle_high_contrast.toggled.connect(_on_high_contrast_toggled)
    content.add_child(_toggle_high_contrast)

    _toggle_reduce_motion = CheckButton.new()
    _toggle_reduce_motion.text = "Bewegung reduzieren"
    _toggle_reduce_motion.toggled.connect(_on_reduce_motion_toggled)
    content.add_child(_toggle_reduce_motion)

    _toggle_effects = CheckButton.new()
    _toggle_effects.text = "Effekte & Partikel aktiv"
    _toggle_effects.toggled.connect(_on_effects_toggled)
    content.add_child(_toggle_effects)

    _options_dialog.add_child(content)
    add_child(_options_dialog)

func _ensure_quit_dialog() -> void:
    if _quit_dialog:
        return

    _quit_dialog = ConfirmationDialog.new()
    _quit_dialog.title = "Spiel beenden"
    _quit_dialog.dialog_text = "Möchtest du das Spiel wirklich verlassen?"
    _quit_dialog.ok_button_text = "Ja"
    _quit_dialog.cancel_button_text = "Nein"
    _quit_dialog.confirmed.connect(_do_quit)
    add_child(_quit_dialog)

func _sync_option_states() -> void:
    if not _options_dialog:
        return
    _syncing_options = true
    if _toggle_high_contrast:
        _toggle_high_contrast.button_pressed = bool(GameState.get_setting("high_contrast", false))
    if _toggle_reduce_motion:
        _toggle_reduce_motion.button_pressed = bool(GameState.get_setting("reduce_motion", false))
    if _toggle_effects:
        _toggle_effects.button_pressed = bool(GameState.get_setting("effects_enabled", true))
    _syncing_options = false

func _on_high_contrast_toggled(pressed: bool) -> void:
    if _syncing_options:
        return
    GameState.set_setting("high_contrast", pressed)
    UIManager.apply_high_contrast(pressed)
    GameState.save_settings()

func _on_reduce_motion_toggled(pressed: bool) -> void:
    if _syncing_options:
        return
    _reduce_motion_enabled = pressed
    GameState.set_setting("reduce_motion", pressed)
    UIManager.apply_reduce_motion(pressed)
    GameState.save_settings()

func _on_effects_toggled(pressed: bool) -> void:
    if _syncing_options:
        return
    _effects_enabled = pressed
    GameState.set_setting("effects_enabled", pressed)
    UIManager.apply_effects_enabled(pressed)
    GameState.save_settings()

func _do_quit() -> void:
    if OS.has_feature("web"):
        var note := AcceptDialog.new()
        note.title = "Danke fürs Spielen!"
        note.dialog_text = "Web-Builds können das Fenster nicht schließen."
        add_child(note)
        note.popup_centered()
    else:
        get_tree().quit()
