extends Node
class_name UIManager

var high_contrast_enabled: bool = false
var reduce_motion_enabled: bool = false
var effects_enabled: bool = true

func toast(msg: String) -> void:
    print("[UI] ", msg)

func apply_high_contrast(enabled: bool) -> void:
    high_contrast_enabled = enabled
    print("High contrast:", enabled)

func apply_reduce_motion(enabled: bool) -> void:
    reduce_motion_enabled = enabled
    print("Reduce motion:", enabled)

func apply_effects_enabled(enabled: bool) -> void:
    effects_enabled = enabled
    print("Effects enabled:", enabled)
