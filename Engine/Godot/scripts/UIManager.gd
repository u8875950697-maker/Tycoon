extends Node
class_name UIManager

func show_window(window: Window) -> void:
    if window:
        window.popup_centered()

func hide_window(window: Window) -> void:
    if window:
        window.hide()
