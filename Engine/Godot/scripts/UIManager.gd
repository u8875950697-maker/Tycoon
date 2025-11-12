extends CanvasLayer
class_name UIManager

var screens := {}

func register_screen(name: String, node: Node) -> void:
    screens[name] = node

func show_screen(name: String) -> void:
    for key in screens.keys():
        var screen := screens[key]
        screen.visible = (key == name)

func hide_all() -> void:
    for screen in screens.values():
        screen.visible = false
