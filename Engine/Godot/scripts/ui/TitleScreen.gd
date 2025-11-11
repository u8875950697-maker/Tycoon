extends Node

@onready var play_btn    : Button = $"../VBox/Buttons/PlayButton"
@onready var options_btn : Button = $"../VBox/Buttons/OptionsButton"
@onready var quit_btn    : Button = $"../VBox/Buttons/QuitButton"

const WORLD_SCENE := "res://Engine/Godot/scenes/WorldScene.tscn"

func _ready() -> void:
    play_btn.pressed.connect(_play)
    options_btn.pressed.connect(_opts)
    quit_btn.pressed.connect(_quit)

func _play() -> void:
    if ResourceLoader.exists(WORLD_SCENE):
        get_tree().change_scene_to_file(WORLD_SCENE)
    else:
        push_error("WorldScene missing: %s" % WORLD_SCENE)

func _opts() -> void:
    var d := AcceptDialog.new()
    d.title = "Options"
    d.dialog_text = "Options dialog placeholder."
    add_child(d)
    d.popup_centered()

func _quit() -> void:
    if OS.has_feature("web"):
        var d := AcceptDialog.new()
        d.title = "Thanks!"
        d.dialog_text = "Web builds cannot close the window."
        add_child(d)
        d.popup_centered()
    else:
        get_tree().quit()
