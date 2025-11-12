extends Node
class_name WorldController

@export var grid_size: Vector2i = Vector2i(4, 4)
@export var cell_size: Vector2 = Vector2(1.5, 1.5)

func grid_to_world(ix: int, iy: int) -> Vector3:
    var origin_x := (grid_size.x - 1) * 0.5 * cell_size.x
    var origin_y := (grid_size.y - 1) * 0.5 * cell_size.y
    return Vector3(ix * cell_size.x - origin_x, 0.0, iy * cell_size.y - origin_y)
