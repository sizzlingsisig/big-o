extends RefCounted
class_name SectorGrid

## Shared helpers for converting world positions into sector grid coordinates.

static func get_sector_at_position(pos: Vector2) -> Vector2i:
	var sector_size: float = BigOConstants.SECTOR_SIZE
	return Vector2i(int(pos.x / sector_size), int(pos.y / sector_size))

static func get_sector_center(coords: Vector2i) -> Vector2:
	var sector_size: float = BigOConstants.SECTOR_SIZE
	return Vector2(
		coords.x * sector_size + (sector_size / 2.0),
		coords.y * sector_size + (sector_size / 2.0)
	)

static func get_half_sector_size() -> float:
	return BigOConstants.SECTOR_SIZE / 2.0

static func get_adjacent_sectors(center: Vector2i, radius: int) -> Array[Vector2i]:
	var sectors: Array[Vector2i] = []
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			sectors.append(center + Vector2i(x, y))
	return sectors
