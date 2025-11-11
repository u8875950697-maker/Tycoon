extends Node
class_name WorldController

# Very small world/grid utilities – safe defaults
var grid_size: Vector2i = Vector2i(4, 4)
var cell_world_size: Vector2 = Vector2(1.5, 1.5)

func grid_to_world(ix: int, iy: int) -> Vector3:
    return Vector3(ix * cell_world_size.x - ((grid_size.x - 1) * 0.5 * cell_world_size.x),
                   0.0,
                   iy * cell_world_size.y - ((grid_size.y - 1) * 0.5 * cell_world_size.y))
