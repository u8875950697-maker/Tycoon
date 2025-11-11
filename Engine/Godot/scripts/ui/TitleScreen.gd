extends CanvasLayer

@onready var play_button: Button = %PlayButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton
@onready var options_dialog: Window = %OptionsDialog
@onready var leaves_particles: CPUParticles2D = %Leaves
@onready var parallax_background: ParallaxBackground = $Parallax
@onready var board_panel: Panel = %Board
@onready var title_label: Label = %Title
@onready var subtitle_label: Label = %Subtitle
@onready var footer_label: Label = %Footer

var reduce_motion_enabled := false
var scroll_speed := 18.0

func _ready() -> void:
    if play_button:
        play_button.pressed.connect(_on_play_pressed)
    if options_button:
        options_button.pressed.connect(_on_options_pressed)
    if quit_button:
        quit_button.pressed.connect(_on_quit_pressed)
    if options_dialog:
        options_dialog.close_requested.connect(_on_options_closed)
        if options_dialog.has_signal("setting_changed"):
            options_dialog.setting_changed.connect(_on_setting_changed)
    reduce_motion_enabled = GameState.get_setting("reduce_motion", false)
    UIManager.apply_reduce_motion(reduce_motion_enabled)
    UIManager.apply_high_contrast(GameState.get_setting("high_contrast", false))
    _apply_motion_setting()
    _apply_high_contrast(GameState.get_setting("high_contrast", false))

func _on_play_pressed() -> void:
    if options_dialog and options_dialog.visible:
        options_dialog.hide()
    get_tree().change_scene_to_file("res://scenes/WorldScene.tscn")

func _on_options_pressed() -> void:
    if options_dialog:
        options_dialog.popup_centered()

func _on_quit_pressed() -> void:
    get_tree().quit()

func _on_options_closed() -> void:
    if options_dialog:
        options_dialog.hide()

func _on_setting_changed(key: String, value) -> void:
    match key:
        "reduce_motion":
            reduce_motion_enabled = bool(value)
            _apply_motion_setting()
        "high_contrast":
            _apply_high_contrast(bool(value))

func _apply_motion_setting() -> void:
    if leaves_particles:
        leaves_particles.emitting = not reduce_motion_enabled
        leaves_particles.amount = 60 if not reduce_motion_enabled else 18
    if parallax_background and reduce_motion_enabled:
        parallax_background.scroll_offset = Vector2.ZERO

func _apply_high_contrast(enabled: bool) -> void:
    if board_panel:
        board_panel.self_modulate = Color(0.22, 0.2, 0.18, 0.96) if enabled else Color(0.82, 0.7, 0.52, 0.95)
    var label_color := Color(1, 1, 1, 1) if enabled else Color(0.13, 0.22, 0.15, 1)
    if title_label:
        title_label.add_theme_color_override("font_color", label_color)
    if subtitle_label:
        var sub_color := Color(0.85, 0.95, 0.9, 1) if enabled else Color(0.2, 0.33, 0.25, 1)
        subtitle_label.add_theme_color_override("font_color", sub_color)
    if footer_label:
        var footer_color := Color(0.9, 0.95, 0.92, 1) if enabled else Color(0.18, 0.28, 0.22, 1)
        footer_label.add_theme_color_override("font_color", footer_color)

func _process(delta: float) -> void:
    if parallax_background == null or reduce_motion_enabled:
        return
    var offset := parallax_background.scroll_offset
    offset.x = fmod(offset.x + scroll_speed * delta, 1024.0)
    parallax_background.scroll_offset = offset
