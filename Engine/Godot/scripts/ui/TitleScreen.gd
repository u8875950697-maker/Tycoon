extends Node

@onready var play_btn    : Button = $"../VBox/Buttons/PlayButton"
@onready var options_btn : Button = $"../VBox/Buttons/OptionsButton"
@onready var quit_btn    : Button = $"../VBox/Buttons/QuitButton"



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
