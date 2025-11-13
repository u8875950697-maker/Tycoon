extends Node

func toast(msg: String) -> void:
    print("[UI] ", msg)

func apply_high_contrast(enabled: bool) -> void:
    print("High contrast:", enabled)

func apply_reduce_motion(enabled: bool) -> void:
    print("Reduce motion:", enabled)

func apply_effects_enabled(enabled: bool) -> void:
    print("Effects enabled:", enabled)
