extends CanvasLayer
class_name TitleScreen

const WORLD_SCENE := "res://Engine/Godot/scenes/WorldScene.tscn"

@onready var play_btn: Button = $VBox/Buttons/PlayButton
@onready var options_btn: Button = $VBox/Buttons/OptionsButton
@onready var quit_btn: Button = $VBox/Buttons/QuitButton
@onready var options_dialog: AcceptDialog = $OptionsDialog

func _ready() -> void:
    play_btn.pressed.connect(_on_play_pressed)
    options_btn.pressed.connect(_on_options_pressed)
    quit_btn.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
    if ResourceLoader.exists(WORLD_SCENE):
        get_tree().change_scene_to_file(WORLD_SCENE)
    else:
        push_error("World scene missing at %s" % WORLD_SCENE)

func _on_options_pressed() -> void:
    options_dialog.dialog_text = "Additional options will be added later."
    options_dialog.popup_centered()

func _on_quit_pressed() -> void:
    if OS.has_feature("web"):
        options_dialog.dialog_text = "Web builds cannot close the window."
        options_dialog.popup_centered()
    else:
        get_tree().quit()
