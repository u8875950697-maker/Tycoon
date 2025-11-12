extends Node

@onready var play_btn     : Button = $"../VBox/Buttons/PlayButton"
@onready var options_btn  : Button = $"../VBox/Buttons/OptionsButton"
@onready var quit_btn     : Button = $"../VBox/Buttons/QuitButton"

const WORLD_SCENE := "res://Engine/Godot/scenes/WorldScene.tscn"
var options_dialog: AcceptDialog

func _ready() -> void:
    options_dialog = AcceptDialog.new()
    options_dialog.title = "Options"
    add_child(options_dialog)
    play_btn.pressed.connect(_on_play)
    options_btn.pressed.connect(_on_options)
    quit_btn.pressed.connect(_on_quit)

func _on_play() -> void:
    if ResourceLoader.exists(WORLD_SCENE):
        get_tree().change_scene_to_file(WORLD_SCENE)
    else:
        push_error("WorldScene not found at: %s" % WORLD_SCENE)

func _on_options() -> void:
    options_dialog.dialog_text = "Options dialog placeholder."
    options_dialog.popup_centered()

func _on_quit() -> void:
    if OS.has_feature("web"):
        options_dialog.title = "Thanks!"
        options_dialog.dialog_text = "Web builds cannot close the window."
        options_dialog.popup_centered()
    else:
        get_tree().quit()
