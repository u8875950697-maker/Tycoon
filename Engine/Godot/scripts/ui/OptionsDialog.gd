extends Window

signal setting_changed(key: String, value)

@onready var close_button: Button = %CloseButton
@onready var mute_music: CheckBox = %MuteMusic
@onready var mute_sfx: CheckBox = %MuteSfx
@onready var high_contrast: CheckBox = %HighContrast
@onready var reduce_motion: CheckBox = %ReduceMotion

func _ready() -> void:
    if close_button:
        close_button.pressed.connect(_on_close_pressed)
        close_requested.connect(_on_close_pressed)
    if mute_music:
        mute_music.toggled.connect(_on_mute_music)
    if mute_sfx:
        mute_sfx.toggled.connect(_on_mute_sfx)
    if high_contrast:
        high_contrast.toggled.connect(_on_high_contrast)
    if reduce_motion:
        reduce_motion.toggled.connect(_on_reduce_motion)
    _apply_saved_settings()

func _apply_saved_settings() -> void:
    var settings := GameState.get_all_settings()
    if mute_music:
        mute_music.button_pressed = bool(settings.get("mute_music", false))
    if mute_sfx:
        mute_sfx.button_pressed = bool(settings.get("mute_sfx", false))
    if high_contrast:
        high_contrast.button_pressed = bool(settings.get("high_contrast", false))
    if reduce_motion:
        reduce_motion.button_pressed = bool(settings.get("reduce_motion", false))

func _on_close_pressed() -> void:
    hide()

func _on_mute_music(value: bool) -> void:
    GameState.set_setting("mute_music", value)
    _update_audio_bus("Music", value)
    emit_signal("setting_changed", "mute_music", value)

func _on_mute_sfx(value: bool) -> void:
    GameState.set_setting("mute_sfx", value)
    _update_audio_bus("SFX", value)
    emit_signal("setting_changed", "mute_sfx", value)

func _on_high_contrast(value: bool) -> void:
    GameState.set_setting("high_contrast", value)
    UIManager.apply_high_contrast(value)
    emit_signal("setting_changed", "high_contrast", value)

func _on_reduce_motion(value: bool) -> void:
    GameState.set_setting("reduce_motion", value)
    UIManager.apply_reduce_motion(value)
    emit_signal("setting_changed", "reduce_motion", value)

func _update_audio_bus(bus_name: String, mute: bool) -> void:
    var index := AudioServer.get_bus_index(bus_name)
    if index == -1:
        index = AudioServer.get_bus_index("Master")
    if index != -1:
        AudioServer.set_bus_mute(index, mute)
