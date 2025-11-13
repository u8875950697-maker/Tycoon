extends Window
class_name OptionsDialog

@onready var mute_music: CheckBox = %MuteMusic if has_node("%MuteMusic") else null
@onready var mute_sfx: CheckBox = %MuteSfx if has_node("%MuteSfx") else null
@onready var high_contrast: CheckBox = %HighContrast if has_node("%HighContrast") else null
@onready var reduce_motion: CheckBox = %ReduceMotion if has_node("%ReduceMotion") else null
@onready var close_button: Button = %CloseButton if has_node("%CloseButton") else null

func _ready() -> void:
    _apply_initial_values()
    if mute_music:
        mute_music.toggled.connect(_on_mute_music_toggled)
    if mute_sfx:
        mute_sfx.toggled.connect(_on_mute_sfx_toggled)
    if high_contrast:
        high_contrast.toggled.connect(_on_high_contrast_toggled)
    if reduce_motion:
        reduce_motion.toggled.connect(_on_reduce_motion_toggled)
    if close_button:
        close_button.pressed.connect(_on_close_pressed)

func _apply_initial_values() -> void:
    if mute_music:
        mute_music.button_pressed = bool(GameState.get_setting("mute_music", false))
    if mute_sfx:
        mute_sfx.button_pressed = bool(GameState.get_setting("mute_sfx", false))
    if high_contrast:
        var enabled := bool(GameState.get_setting("high_contrast", false))
        high_contrast.button_pressed = enabled
        UIManager.apply_high_contrast(enabled)
    if reduce_motion:
        var enabled_rm := bool(GameState.get_setting("reduce_motion", false))
        reduce_motion.button_pressed = enabled_rm
        UIManager.apply_reduce_motion(enabled_rm)

func _on_mute_music_toggled(pressed: bool) -> void:
    GameState.set_setting("mute_music", pressed)

func _on_mute_sfx_toggled(pressed: bool) -> void:
    GameState.set_setting("mute_sfx", pressed)

func _on_high_contrast_toggled(pressed: bool) -> void:
    GameState.set_setting("high_contrast", pressed)
    UIManager.apply_high_contrast(pressed)
    UIManager.toast("High contrast %s" % ("enabled" if pressed else "disabled"))

func _on_reduce_motion_toggled(pressed: bool) -> void:
    GameState.set_setting("reduce_motion", pressed)
    UIManager.apply_reduce_motion(pressed)
    UIManager.toast("Reduce motion %s" % ("enabled" if pressed else "disabled"))

func _on_close_pressed() -> void:
    hide()
