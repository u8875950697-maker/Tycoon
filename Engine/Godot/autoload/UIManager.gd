extends Node
class_name UIManager

signal high_contrast_changed(enabled: bool)
signal reduce_motion_changed(enabled: bool)

var _registered_topbars: Array = []
var _registered_worlds: Array = []
var _high_contrast_enabled := false
var _reduce_motion_enabled := false

func register_top_bar(node: Node) -> void:
    if node == null:
        return
    if _registered_topbars.has(node):
        return
    _registered_topbars.append(node)
    if node.has_method("apply_high_contrast"):
        node.apply_high_contrast(_high_contrast_enabled)

func unregister_top_bar(node: Node) -> void:
    if node == null:
        return
    _registered_topbars.erase(node)

func register_world_scene(node: Node) -> void:
    if node == null:
        return
    if _registered_worlds.has(node):
        return
    _registered_worlds.append(node)
    if node.has_method("apply_reduce_motion"):
        node.apply_reduce_motion(_reduce_motion_enabled)

func unregister_world_scene(node: Node) -> void:
    if node == null:
        return
    _registered_worlds.erase(node)

func show_popup(window: Node) -> void:
    if window and window is Window:
        (window as Window).popup_centered()

func hide_popup(window: Node) -> void:
    if window and window is Window:
        (window as Window).hide()

func apply_high_contrast(enabled: bool) -> void:
    _high_contrast_enabled = enabled
    for node in _registered_topbars:
        if is_instance_valid(node) and node.has_method("apply_high_contrast"):
            node.apply_high_contrast(enabled)
    emit_signal("high_contrast_changed", enabled)

func apply_reduce_motion(enabled: bool) -> void:
    _reduce_motion_enabled = enabled
    for node in _registered_worlds:
        if is_instance_valid(node) and node.has_method("apply_reduce_motion"):
            node.apply_reduce_motion(enabled)
    emit_signal("reduce_motion_changed", enabled)

func is_high_contrast_enabled() -> bool:
    return _high_contrast_enabled

func is_reduce_motion_enabled() -> bool:
    return _reduce_motion_enabled
