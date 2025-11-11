extends Node
class_name UIManager

# Minimal UI router – placeholders
func show_popup(p: Node) -> void:
    if p and p is Window:
        (p as Window).popup_centered()

func hide_popup(p: Node) -> void:
    if p and p is Window:
        (p as Window).hide()
