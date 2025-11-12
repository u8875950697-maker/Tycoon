extends Node

@onready var play_btn    : Button = $"../VBox/Buttons/PlayButton"
@onready var options_btn : Button = $"../VBox/Buttons/OptionsButton"
@onready var quit_btn    : Button = $"../VBox/Buttons/QuitButton"

var _dialog: AcceptDialog

const WORLD_SCENE := "res://scenes/WorldScene.tscn"
const WORLD_SCENE_FALLBACK := "res://Engine/Godot/scenes/WorldScene.tscn"

func _ready() -> void:
    play_btn.pressed.connect(_play)
    options_btn.pressed.connect(_opts)
    quit_btn.pressed.connect(_quit)
    _ensure_dialog()

func _play() -> void:
    var path := WORLD_SCENE
    if not ResourceLoader.exists(path) and ResourceLoader.exists(WORLD_SCENE_FALLBACK):
        path = WORLD_SCENE_FALLBACK
    if ResourceLoader.exists(path):
        get_tree().change_scene_to_file(path)
    else:
        push_error("WorldScene missing: %s" % WORLD_SCENE)

func _opts() -> void:
    _ensure_dialog()
    _dialog.title = "Options"
    _dialog.dialog_text = "Options dialog placeholder."
    _dialog.popup_centered()

func _quit() -> void:
    _ensure_dialog()
    if OS.has_feature("web"):
        _dialog.title = "Thanks!"
        _dialog.dialog_text = "Web builds cannot close the window."
        _dialog.popup_centered()
    else:
        get_tree().quit()

func _ensure_dialog() -> void:
    if _dialog:
        return
    _dialog = AcceptDialog.new()
    add_child(_dialog)
