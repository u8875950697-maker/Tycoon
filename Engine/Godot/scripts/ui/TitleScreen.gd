extends Node

@onready var play_btn: Button = $"../UIRoot/Board/VBox/Buttons/PlayButton"
@onready var options_btn: Button = $"../UIRoot/Board/VBox/Buttons/OptionsButton"
@onready var quit_btn: Button = $"../UIRoot/Board/VBox/Buttons/QuitButton"
@onready var options_dlg: Window = $"../UIRoot/OptionsDialog"
@onready var parallax: ParallaxBackground = $"../Parallax"

const WORLD_SCENE := "res://scenes/WorldScene.tscn"
var _t := 0.0

func _ready() -> void:
    if play_btn:
        play_btn.pressed.connect(_on_play)
    if options_btn:
        options_btn.pressed.connect(_on_options)
    if quit_btn:
        quit_btn.pressed.connect(_on_quit)

func _process(delta: float) -> void:
    if parallax:
        _t += delta
        parallax.scroll_offset.x = sin(_t * 0.2) * 40.0

func _on_play() -> void:
    if ResourceLoader.exists(WORLD_SCENE):
        get_tree().change_scene_to_file(WORLD_SCENE)
    else:
        push_error("WorldScene not found at: %s" % WORLD_SCENE)

func _on_options() -> void:
    if options_dlg:
        options_dlg.popup_centered()

func _on_quit() -> void:
    if OS.has_feature("web"):
        var dlg := AcceptDialog.new()
        dlg.title = "Thanks for playing!"
        dlg.dialog_text = "Web builds cannot close the window."
        add_child(dlg)
        dlg.popup_centered()
    else:
        get_tree().quit()
