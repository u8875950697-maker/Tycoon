extends Node

@onready var btn_play: Button   = $"../VBox/Play"
@onready var btn_opts: Button   = $"../VBox/Options"
@onready var btn_quit: Button   = $"../VBox/Quit"

@onready var layer_hills: ColorRect  = $"../LayerHills"
@onready var layer_trees: ColorRect  = $"../LayerTrees"

const WORLD_SCENE := "res://scenes/WorldScene.tscn"

var t: float = 0.0

func _ready() -> void:
    if btn_play:
        btn_play.pressed.connect(_play)
    if btn_opts:
        btn_opts.pressed.connect(_opts)
    if btn_quit:
        btn_quit.pressed.connect(_quit)

func _process(delta: float) -> void:
    t += delta
    # very light fake parallax motion
    if layer_hills:
        layer_hills.position.x = sin(t * 0.2) * 8.0
    if layer_trees:
        layer_trees.position.x = cos(t * 0.3) * 10.0

func _play() -> void:
    if ResourceLoader.exists(WORLD_SCENE):
        get_tree().change_scene_to_file(WORLD_SCENE)
    else:
        push_error("WorldScene missing: %s" % WORLD_SCENE)

func _opts() -> void:
    var d := AcceptDialog.new()
    d.title = "Options"
    d.dialog_text = "High contrast / reduce motion will be hooked up later."
    add_child(d)
    d.popup_centered()

func _quit() -> void:
    if OS.has_feature("web"):
        var d := AcceptDialog.new()
        d.title = "Cannot Quit"
        d.dialog_text = "Web builds cannot close the window."
        add_child(d)
        d.popup_centered()
    else:
        get_tree().quit()
