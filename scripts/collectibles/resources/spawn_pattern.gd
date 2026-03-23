extends Resource
class_name SpawnPattern

## A resource defining a geometric pattern for spawning collectibles within a sector.
## Points should be defined relative to the sector's center point.

@export var name: String = "Pattern"
@export var relative_positions: Array[Vector2] = []

static func create_scatter(amount: int, spread: float = 1000.0) -> SpawnPattern:
	var pattern = SpawnPattern.new()
	pattern.name = "Scatter"
	for i in range(amount):
		pattern.relative_positions.append(Vector2(randf_range(-spread, spread), randf_range(-spread, spread)))
	return pattern

static func create_circle(amount: int, radius: float = 800.0) -> SpawnPattern:
	var pattern = SpawnPattern.new()
	pattern.name = "Circle"
	var angle_step = TAU / amount
	for i in range(amount):
		pattern.relative_positions.append(Vector2.from_angle(i * angle_step) * radius)
	return pattern

static func create_grid(rows: int, cols: int, spacing: float = 200.0) -> SpawnPattern:
	var pattern = SpawnPattern.new()
	pattern.name = "Grid"
	var start_x = -(cols - 1) * spacing / 2.0
	var start_y = -(rows - 1) * spacing / 2.0
	for r in range(rows):
		for c in range(cols):
			pattern.relative_positions.append(Vector2(start_x + c * spacing, start_y + r * spacing))
	return pattern

static func create_line(amount: int, length: float = 1500.0, angle: float = 0.0) -> SpawnPattern:
	var pattern = SpawnPattern.new()
	pattern.name = "Line"
	var dir = Vector2.from_angle(angle)
	var start_pos = -dir * (length / 2.0)
	var step = length / max(1, amount - 1)
	for i in range(amount):
		pattern.relative_positions.append(start_pos + dir * (i * step))
	return pattern